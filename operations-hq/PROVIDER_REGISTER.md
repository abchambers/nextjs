# Weather Data Provider Register

This register is an operating inventory, not legal advice. Before monetizing a source-dependent feature, confirm current terms with the provider and retain the review date, plan, attribution language, and internal owner.

## Current integrations observed in the codebase

| Provider/source | Current product use | Commercial launch posture | Required action | Owner |
| --- | --- | --- | --- | --- |
| NOAA / NWS | Observations, alerts, forecast guidance, NDFD map layers, NBM-derived guidance | Review and preserve required context/attribution; do not imply NOAA/NWS endorsement | Add formal attribution/disclaimer review and source freshness handling | Unassigned |
| NOAA / SPC | Observed upper-air sounding text/images | Review presentation/attribution and source availability | Add source provenance and stale/unavailable state | Unassigned |
| NOAA / NESDIS | GOES satellite image | Review image/product-specific usage and attribution | Confirm the exact feed’s terms before broader commercialization | Unassigned |
| Open-Meteo | Point model guidance, ensembles, archived model soundings | **Commercial subscription required for a paid/subscription/ad-supported product** | Select appropriate paid plan before commercial launch; retain attribution | Unassigned |
| RainViewer | Radar timeline frames/tiles | **Free API is personal, educational, and small-scale community use; not a high-volume commercial dependency** | Obtain commercial terms or replace for commercial/public scale; keep visible attribution | Unassigned |
| OpenWeather | Surface-map tiles | Depends on account plan/terms | Confirm the plan allows intended traffic and product use; monitor key spend | Unassigned |
| OpenStreetMap tiles | Base map imagery | Public tile service has usage policy; do not assume it scales for commercial traffic | Review tile policy and move to a suitable tile provider before scale | Unassigned |
| Leaflet | Map rendering library loaded from CDN | Open-source library; verify version/license notices | Pin/review dependency and retain applicable notices | Unassigned |

## Immediate launch gates

1. Do not launch a paid public radar/model product relying on free RainViewer or free Open-Meteo access without the proper commercial arrangement.
2. Keep source names and attribution visible where required.
3. Label data source, fetch time, and stale/unavailable state—especially for forecasts, radar, and observations.
4. Track requests and cache behavior before inviting a larger cohort.
5. Maintain provider fallback plans; a vendor outage must degrade a view honestly rather than create fake weather guidance.

## Source-review record template

Copy this for each provider before a commercial feature goes live:

```text
Provider:
Feature(s) powered:
Product tier(s) using it:
Plan/contract:
Commercial use confirmed by:
Attribution text/location:
Rate/cost limit:
Caching/storage/redistribution rules:
Outage fallback:
Review date / next review:
Internal owner:
```

## Notes from current provider documentation

- NWS describes its API information as open data/free to use, subject to reasonable rate limits; its disclaimer also says not to present altered material as official or imply endorsement. [NWS API documentation](https://www.weather.gov/documentation/services-web-api?prevfmt=application%2Fcap%2Bxml&prevopt=id%3DNWS-IDP-PROD-3734524), [NWS disclaimer](https://www.weather.gov/index.php/disclaimer/)
- Open-Meteo states that free API use is non-commercial and asks commercial users to use an API plan; its API data uses CC BY 4.0 attribution terms. [Open-Meteo terms](https://open-meteo.com/en/terms), [Open-Meteo license](https://open-meteo.com/en/license)
- RainViewer’s public API documentation says its free tier is for personal, educational, and small-scale community use, requires attribution, and is not intended for high-volume commercial use. [RainViewer API documentation](https://www.rainviewer.com/api.html)
