import QtQuick

ApiStrategy {
    function buildEndpoint(model: AiModel): string {
        return model.endpoint;
    }

    function buildRequestData(model: AiModel, messages, systemPrompt: string, temperature: real, tools: list<var>, filePath: string) {
        let chatMessages = [
            {role: "system", content: systemPrompt},
            ...messages.map(m => ({role: m.role, content: m.rawContent}))
        ];
        let baseData = {
            "model": model.model,
            "messages": chatMessages,
            "stream": true,
            "options": {
                "temperature": temperature
            }
        };
        if (tools.length > 0) baseData.tools = tools;
        return model.extraParams ? Object.assign({}, baseData, model.extraParams) : baseData;
    }

    function buildAuthorizationHeader(apiKeyEnvVarName: string): string {
        return "";
    }

    function parseResponseLine(line, message) {
        let cleanData = line.trim();
        if (!cleanData) return {};

        try {
            const dataJson = JSON.parse(cleanData);

            if (dataJson.error) {
                const errorMsg = `**Error**: ${dataJson.error}`;
                message.rawContent += errorMsg;
                message.content += errorMsg;
                return { finished: true };
            }

            const content = dataJson.message?.content;
            if (content && content.length > 0) {
                message.content += content;
                message.rawContent += content;
            }

            if (dataJson.done) {
                return { finished: true };
            }

        } catch (e) {
            console.log("[AI] Ollama: Could not parse line: ", e);
            message.rawContent += line;
            message.content += line;
        }

        return {};
    }

    function onRequestFinished(message) {
        return {};
    }

    function reset() {
    }
}
