// Weather service using wttr.in with hardcoded coordinates as fallback.
// Configure your location via:
//   - GPS (bar.weather.enableGPS = true) - requires GeoClue
//   - Hardcoded coordinates in getData() below (edit the fallback lat/long)
//   - City name (bar.weather.city) is used as display label only, not for API queries
// Temperature unit: bar.weather.useUSCS (Fahrenheit when true, Celsius when false)
// Polling interval: bar.weather.fetchInterval (minutes)
pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtPositioning

import "root:/modules/common"

Singleton {
    id: root

    readonly property int fetchInterval: Config.options.bar.weather.fetchInterval * 60 * 1000
    readonly property bool useUSCS: Config.options.bar.weather.useUSCS
    property bool gpsActive: false

    property var location: ({
        valid: false,
        lat: 0,
        lon: 0
    })

    property var data: ({
        uv: 0,
        humidity: 0,
        sunrise: 0,
        sunset: 0,
        windDir: 0,
        wCode: 0,
        city: "Loading...",
        wind: 0,
        precip: 0,
        visib: 0,
        press: 0,
        temp: 0,
        tempFeelsLike: 0,
        lastRefresh: 0
    })

    function refineData(data) {
        let temp = {};
        temp.uv = data?.current?.uvIndex || 0;
        temp.humidity = (data?.current?.humidity || 0) + "%";
        temp.sunrise = data?.astronomy?.sunrise || "0.0";
        temp.sunset = data?.astronomy?.sunset || "0.0";
        temp.windDir = data?.current?.winddir16Point || "N";
        temp.wCode = data?.current?.weatherCode || "113";

        // City from API response, or user-configured fallback name
        temp.city = data?.location?.areaName[0]?.value
            || Config.options.bar.weather.city
            || "Unknown City";

        if (root.useUSCS) {
            // Imperial (USCS) formatting
            temp.wind = (data?.current?.windspeedMiles || 0) + " mph";
            temp.precip = ((data?.current?.precipMM || 0) * 0.0393701).toFixed(2) + " in";
            temp.visib = ((data?.current?.visibility || 0) * 0.621371).toFixed(1) + " mi";
            temp.press = (data?.current?.pressure || 0) + " hPa";
            temp.temp = (data?.current?.temp_F || 0) + "°F";
            temp.tempFeelsLike = (data?.current?.FeelsLikeF || 0) + "°F";
        } else {
            // Metric (SI) formatting
            temp.wind = (data?.current?.windspeedKmph || 0) + " km/h";
            temp.precip = (data?.current?.precipMM || 0) + " mm";
            temp.visib = (data?.current?.visibility || 0) + " km";
            temp.press = (data?.current?.pressure || 0) + " hPa";
            temp.temp = (data?.current?.temp_C || 0) + "°C";
            temp.tempFeelsLike = (data?.current?.FeelsLikeC || 0) + "°C";
        }

        temp.lastRefresh = DateTime.time + " • " + DateTime.date;
        root.data = temp;
    }

    function getData() {
        let command = "curl -s wttr.in";

        if (root.gpsActive && root.location.valid) {
            command += `/${root.location.lat},${root.location.long}`;
        } else {
            // Hardcoded coordinates - edit these to your location
            command += "/35.759200,-90.323100";
        }

        command += "?format=j1 | jq '{current: .current_condition[0], location: .nearest_area[0], astronomy: .weather[0].astronomy[0]}'";
        fetcher.command[2] = command;
        fetcher.running = true;
    }

    Component.onCompleted: {
        if (!root.gpsActive) return;
        console.info("[WeatherService] Starting the GPS service.");
        positionSource.start();
    }

    Process {
        id: fetcher
        command: ["bash", "-c", ""]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0) return;
                try {
                    const parsedData = JSON.parse(text);
                    root.refineData(parsedData);
                } catch (e) {
                    console.error(`[WeatherService] ${e.message}`);
                }
            }
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: root.fetchInterval

        onPositionChanged: {
            if (position.latitudeValid && position.longitudeValid) {
                root.location.lat = position.coordinate.latitude;
                root.location.long = position.coordinate.longitude;
                root.location.valid = true;
                root.getData();
            } else {
                root.gpsActive = root.location.valid ? true : false;
                console.error("[WeatherService] Failed to get the GPS location.");
            }
        }

        onValidityChanged: {
            if (!positionSource.valid) {
                positionSource.stop();
                root.location.valid = false;
                root.gpsActive = false;
                Quickshell.execDetached(["bash", "-c", `notify-send WeatherService 'Can not find a GPS service. Using the fallback method instead.'`]);
                console.error("[WeatherService] Could not aquire a valid backend plugin.");
            }
        }
    }

    Timer {
        running: !root.gpsActive
        repeat: true
        interval: root.fetchInterval
        triggeredOnStart: !root.gpsActive
        onTriggered: root.getData()
    }
}
