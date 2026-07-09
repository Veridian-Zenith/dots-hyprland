import QtQuick
import qs.modules.common.functions as CF

ApiStrategy {
    readonly property string apiKeyEnvVarName: "API_KEY"
    readonly property string fileUriVarName: "file_uri"
    readonly property string fileMimeTypeVarName: "MIME_TYPE"
    readonly property string fileUriSubstitutionString: "{{ fileUriVarName }}"
    readonly property string fileMimeTypeSubstitutionString: "{{ fileMimeTypeVarName }}"
    property string buffer: ""
    
    function buildEndpoint(model: AiModel): string {
        const result = model.endpoint + `?key=\$\{${root.apiKeyEnvVarName}\}`
        return result;
    }

    function buildRequestData(model: AiModel, messages, systemPrompt: string, temperature: real, tools: list<var>, filePath: string) {
        let contents = messages.map(message => {
            const geminiApiRoleName = (message.role === "assistant") ? "model" : message.role;
            const usingSearch = tools[0]?.google_search !== undefined;
          
            let parts = [];

            // 1. Handle Function Calls
            if (!usingSearch && message.functionCall !== undefined && message.functionName && message.functionName.length > 0) {
                let partObj = {
                    "functionCall": {
                        "name": message.functionName,
                        "args": message.functionCall.args
                    }
                };
                
                // Ensure thought_signature is present as a sibling to functionCall, not inside it
                partObj["thought_signature"] = message.thought_signature || "context_engineering_is_the_way_to_go";

                parts.push(partObj);

                return {
                    "role": geminiApiRoleName,
                    "parts": parts
                };
            }
            
            // 2. Handle Function Responses
            if (!usingSearch && message.functionResponse !== undefined && message.functionName && message.functionName.length > 0) {
                parts.push({
                    "functionResponse": {
                        "name": message.functionName,
                        "response": { "content": message.functionResponse }
                    }
                });
                return {
                    "role": geminiApiRoleName,
                    "parts": parts
                };
            }

            // 3. Inject Thought/Reasoning part for standard non-tool turns
            if (message.thought_signature && message.thought_signature.length > 0) {
                parts.push({
                    "text": message.thought_signature,
                    "thought": true
                });
            }

            // 4. Handle Standard Text Content
            if (message.rawContent && message.rawContent.length > 0) {
                parts.push({ "text": message.rawContent });
            }
            
            // 5. Handle Associated Inline Media Metadata
            if (message.fileUri && message.fileUri.length > 0) {
                parts.push({
                    "file_data": {
                        "mime_type": message.fileMimeType,
                        "file_uri": message.fileUri
                    }
                });
            }

            return {
                "role": geminiApiRoleName,
                "parts": parts
            };
        });
     
        if (filePath && filePath.length > 0) {
            const trimmedFilePath = CF.FileUtils.trimFileProtocol(filePath);
            contents[contents.length - 1].parts.unshift({
                file_data: {
                    mime_type: fileMimeTypeSubstitutionString,
                    file_uri: fileUriSubstitutionString
                }
            });
        }

        let baseData = {
            "contents": contents,
            "tools": tools,
            "system_instruction": {
                "parts": [{ text: systemPrompt }]
            },
            "generationConfig": {
                "temperature": temperature,
            },
        };
        return model.extraParams ? Object.assign({}, baseData, model.extraParams) : baseData;
    }

    function buildAuthorizationHeader(apiKeyEnvVarName: string): string {
        return "";
    }

    function parseResponseLine(line, message) {
        if (line.startsWith("[")) {
            buffer += line.slice(1).trim();
        } else if (line === "]") {
            buffer += line.slice(0, -1).trim();
            return parseBuffer(message);
        } else if (line.startsWith(",")) {
            return parseBuffer(message);
        } else {
            buffer += line.trim();
        }
        return {};
    }

    function parseBuffer(message) {
        let finished = false;
        try {
            if (buffer.length === 0) return {};
            const dataJson = JSON.parse(buffer);

            if (dataJson.uploadedFile) {
                message.fileUri = dataJson.uploadedFile.uri;
                message.fileMimeType = dataJson.uploadedFile.mimeType;
                return ({});
            }

            if (dataJson.error) {
                const errorMsg = `**Error ${dataJson.error.code}**: ${dataJson.error.message}`;
                message.rawContent += errorMsg;
                message.content += errorMsg;
                return { finished: true };
            }

            if (!dataJson.candidates) return {};
            if (dataJson.candidates[0]?.finishReason) {
                finished = true;
            }
            
            const parts = dataJson.candidates[0]?.content?.parts;
            if (!parts || parts.length === 0) return { finished: finished };

            let textResponse = "";
            let functionCallObj = null;

            // Iterate over all parts returned in the response stream chunk
            for (let i = 0; i < parts.length; i++) {
                const part = parts[i];

                if (part.thought_signature) {
                    message.thought_signature = part.thought_signature;
                }

                // Extract thinking payload if part explicitly flags as thought or text-only reasoning
                if (part.thought === true || (part.text && part.text.trim() && !part.functionCall)) {
                    if (part.thought === true) {
                        message.thought_signature = (message.thought_signature || "") + part.text;
                        continue; 
                    }
                }

                if (part.functionCall) {
                    functionCallObj = part.functionCall;
                }

                if (part.text && !part.thought) {
                    textResponse += part.text;
                }
            }

            // Handle compilation processing for discovered Function Call units
            if (functionCallObj) {
                message.functionName = functionCallObj.name;
                message.functionCall = functionCallObj;
                
                const newContent = `\n\n[[ Function: ${functionCallObj.name}(${JSON.stringify(functionCallObj.args, null, 2)}) ]]\n`;
                message.rawContent += newContent;
                message.content += newContent;

                return { 
                    functionCall: { 
                        name: functionCallObj.name, 
                        args: functionCallObj.args, 
                        thought_signature: message.thought_signature 
                    }, 
                    finished: finished 
                };
            }

            // Handle typical streaming or finalized text compilation segments
            if (textResponse.length > 0) {
                message.rawContent += textResponse;
                message.content += textResponse;
            }
            
            // Handle annotations and metadata
            const annotationSources = dataJson.candidates[0]?.groundingMetadata?.groundingChunks?.map(chunk => {
                return {
                    "type": "url_citation",
                    "text": chunk?.web?.title,
                    "url": chunk?.web?.uri,
                }
            }) ?? [];

            const annotations = dataJson.candidates[0]?.groundingMetadata?.groundingSupports?.map(citation => {
                return {
                    "type": "url_citation",
                    "start_index": citation.segment?.startIndex,
                    "end_index": citation.segment?.endIndex,
                    "text": citation?.segment.text,
                    "url": annotationSources[citation.groundingChunkIndices[0]]?.url,
                    "sources": citation.groundingChunkIndices
                }
            });

            message.annotationSources = annotationSources;
            message.annotations = annotations;
            message.searchQueries = dataJson.candidates[0]?.groundingMetadata?.webSearchQueries ?? [];

            if (dataJson.usageMetadata) {
                return {
                    tokenUsage: {
                        input: dataJson.usageMetadata.promptTokenCount ?? -1,
                        output: dataJson.usageMetadata.candidatesTokenCount ?? -1,
                        total: dataJson.usageMetadata.totalTokenCount ?? -1
                    },
                    finished: finished
                };
            }
            
        } catch (e) {
            console.log("[AI] Gemini: Could not parse buffer: ", e);
            message.rawContent += buffer;
            message.content += buffer;
        } finally {
            buffer = "";
        }
        return { finished: finished };
    }

    function onRequestFinished(message) {
        return parseBuffer(message);
    }
    
    function reset() {
        buffer = "";
    }

    function buildScriptFileSetup(filePath) {
        const trimmedFilePath = CF.FileUtils.trimFileProtocol(filePath);
        let content = "";

        content += `IMAGE_PATH='${CF.StringUtils.shellSingleQuoteEscape(trimmedFilePath)}'\n`;
        content += `${fileMimeTypeVarName}=$(file -b --mime-type "$IMAGE_PATH")\n`;
        content += 'NUM_BYTES=$(wc -c < "${IMAGE_PATH}")\n';
        content += 'tmp_header_file="/tmp/quickshell/ai/upload-header.tmp"\n';
        content += 'tmp_file_info_file="/tmp/quickshell/ai/file-info.json.tmp"\n';
        content += 'curl "https://generativelanguage.googleapis.com/upload/v1beta/files"'
            + ` -H "x-goog-api-key: \$${apiKeyEnvVarName}"`
            + ' -D $tmp_header_file'
            + ' -H "X-Goog-Upload-Protocol: resumable"'
            + ' -H "X-Goog-Upload-Command: start"'
            + ' -H "X-Goog-Upload-Header-Content-Length: ${NUM_BYTES}"'
            + ` -H "X-Goog-Upload-Header-Content-Type: \${${fileMimeTypeVarName}}"`
            + ' -H "Content-Type: application/json"'
            + ` -d "{'file': {'display_name': 'Image'}}" 2> /dev/null`
            + '\n';

        content += 'upload_url=$(grep -i "x-goog-upload-url: " "${tmp_header_file}" | cut -d" " -f2 | tr -d "\r")\n';
        content += 'rm "${tmp_header_file}"\n';

        content += 'curl "${upload_url}"'
            + ` -H "x-goog-api-key: \$${apiKeyEnvVarName}"`
            + ' -H "Content-Length: ${NUM_BYTES}"'
            + ' -H "X-Goog-Upload-Offset: 0"'
            + ' -H "X-Goog-Upload-Command: upload, finalize"'
            + ' --data-binary "@${IMAGE_PATH}" 2> /dev/null > "${tmp_file_info_file}"'
            + '\n';
        content += `${fileUriVarName}=$(jq -r ".file.uri" "$tmp_file_info_file")\n`;
        content += `printf "{\\"uploadedFile\\": {\\"uri\\": \\"$${fileUriVarName}\\", \\"mimeType\\": \\"$${fileMimeTypeVarName}\\"}}\\n,\\n"\n`;

        return content;
    }

    function finalizeScriptContent(scriptContent: string): string {
        return scriptContent.replace(fileMimeTypeSubstitutionString, `'"\$${fileMimeTypeVarName}"'`)
                            .replace(fileUriSubstitutionString, `'"\$${fileUriVarName}"'`);
    }
}
