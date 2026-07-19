"use client";

import { useState } from "react";

type DataPanel = "nbm" | "sounding" | "models";
type WorkspaceSection = "dashboard" | "forecast" | "verify";

export default function Home() {
  const [dataPanel, setDataPanel] = useState<DataPanel>("nbm");
  const [activeSection, setActiveSection] = useState<WorkspaceSection>("dashboard");
  const [radarExpanded, setRadarExpanded] = useState(false);
  const [saveMessage, setSaveMessage] = useState("");

  return (
    <main className={radarExpanded ? "app radar-expanded" : "app"}>
      <header className="header">
        <div><p className="eyebrow">Human-first forecasting workspace</p><h1>The Weather Desk</h1></div>
        <div className="location">Asheville, NC <span>Student workspace</span></div>
      </header>

      <nav aria-label="Main navigation" className="navigation">
        <button className={activeSection === "dashboard" ? "active" : ""} onClick={() => setActiveSection("dashboard")}>Dashboard</button>
        <button className={activeSection === "forecast" ? "active" : ""} onClick={() => setActiveSection("forecast")}>Forecast</button>
        <button className={activeSection === "verify" ? "active" : ""} onClick={() => setActiveSection("verify")}>Verify</button>
      </nav>

      {activeSection === "dashboard" && <>
      <section className="dashboard-grid">
        <article className="radar-card">
          <div className="card-heading"><div><h2>Radar</h2><p>Sample display · updated 2 min ago</p></div><div className="actions"><button>Animate loop</button><button onClick={() => setRadarExpanded((value) => !value)}>{radarExpanded ? "Exit expanded view" : "Expand radar"}</button></div></div>
          <div className="radar" role="img" aria-label="Illustrative radar display showing scattered showers around Asheville">
            <div className="ring ring-one" /><div className="ring ring-two" /><div className="crosshair horizontal" /><div className="crosshair vertical" /><div className="storm storm-one" /><div className="storm storm-two" /><div className="storm storm-three" />
            <div className="radar-label"><strong>Asheville</strong><span>Scattered showers · moving northeast</span></div>
          </div>
          <div className="card-footer"><span>Reflectivity</span><span>Light → moderate</span></div>
        </article>

        <aside className="quick-data" aria-label="Quick weather reference">
          <div><strong>78°F · Mostly cloudy</strong><span>Dew point 68°F · SW 8 mph</span></div>
          <div><strong>NBM: 64% rain chance</strong><span>High 85°F · QPF 0.18 in</span></div>
          <div><strong>12Z sounding</strong><span>MLCAPE 1,150 J/kg · 0–6 km shear 28 kt</span></div>
          <div><strong className="alert">Heat advisory until 8 PM</strong><span>Official NWS alert</span></div>
        </aside>
      </section>

      <section className="data-desk">
        <div className="section-heading"><div><h2>Forecast data desk</h2><p>Full source data for analysis. Quick values remain beside radar.</p></div><span>Archive-ready</span></div>
        <div className="tabs" role="tablist" aria-label="Forecast data sources">
          <button className={dataPanel === "nbm" ? "active" : ""} onClick={() => setDataPanel("nbm")}>NBM full text</button>
          <button className={dataPanel === "sounding" ? "active" : ""} onClick={() => setDataPanel("sounding")}>Sounding</button>
          <button className={dataPanel === "models" ? "active" : ""} onClick={() => setDataPanel("models")}>Other models</button>
        </div>
        {dataPanel === "nbm" && <pre className="model-text">{`NBM 4.2 · KAVL · 2026-07-19 18Z
FHR    TMP  DPT  WDIR  WSPD  SKY  POP  QPF   TSTM
003     82   68   220     8   65   18  0.00    4
006     85   68   230    10   72   42  0.03   14
009     83   69   240     9   84   64  0.18   28
012     77   68   250     6   79   51  0.09   19

Guidance summary: scattered convection favored 3–8 PM; most likely rainfall remains light, but higher local totals are possible.`}</pre>}
        {dataPanel === "sounding" && <div className="sounding"><div className="skew" aria-label="Simplified sounding chart"><i className="temperature" /><i className="dewpoint" /><small>100 hPa</small><small>500 hPa</small><small>Surface</small></div><table><thead><tr><th>Pressure</th><th>Height</th><th>Temp</th><th>Dew point</th><th>Wind</th></tr></thead><tbody><tr><td>1000 hPa</td><td>610 m</td><td>23°C</td><td>19°C</td><td>220° / 8 kt</td></tr><tr><td>850 hPa</td><td>1,510 m</td><td>17°C</td><td>13°C</td><td>235° / 16 kt</td></tr><tr><td>700 hPa</td><td>3,090 m</td><td>7°C</td><td>1°C</td><td>245° / 23 kt</td></tr><tr><td>500 hPa</td><td>5,820 m</td><td>-8°C</td><td>-25°C</td><td>260° / 35 kt</td></tr></tbody></table></div>}
        {dataPanel === "models" && <p className="empty">Start with NBM and observed soundings. Future sources will appear here as timestamped, archivable panels so you can compare them without losing context.</p>}
      </section>
      </>}

      {activeSection === "forecast" && <section className="workspace-card">
        <div className="section-heading"><div><h2>Tuesday forecast</h2><p>Create separate forecasts for the day and night periods.</p></div><span>Draft</span></div>
        <form onSubmit={(event) => { event.preventDefault(); setSaveMessage("Forecast draft saved in this browser session."); }}>
          <fieldset className="forecast-period"><legend>Tuesday day <small>7 AM–7 PM</small></legend><div className="forecast-fields">
            <label>High temperature<input defaultValue="86" inputMode="numeric" /></label>
            <label>Conditions<select defaultValue="storms"><option value="sunny">Mostly sunny</option><option value="storms">Partly cloudy; scattered storms</option><option value="cloudy">Cloudy</option></select></label>
            <label>Rain chance<input defaultValue="60%" /></label>
            <label>Likely timing<input defaultValue="3–8 PM" /></label>
            <label>Wind<input defaultValue="SW 8–12 mph; gusts 20" /></label>
            <label>Confidence<select defaultValue="moderate"><option value="low">Low</option><option value="moderate">Moderate</option><option value="high">High</option></select></label>
            <label className="wide-field">Hazards<input defaultValue="Scattered thunderstorms; brief heavy rain" /></label>
            <label className="wide-field">Day reasoning<textarea defaultValue="Morning clouds should limit heating somewhat, but surface moisture and an approaching boundary support scattered afternoon thunderstorms." /></label>
          </div></fieldset>
          <fieldset className="forecast-period"><legend>Tuesday night <small>7 PM–7 AM</small></legend><div className="forecast-fields">
            <label>Low temperature<input defaultValue="68" inputMode="numeric" /></label>
            <label>Conditions<select defaultValue="showers"><option value="showers">Partly cloudy; isolated shower early</option><option value="clear">Mostly clear</option><option value="cloudy">Cloudy</option></select></label>
            <label>Rain chance<input defaultValue="20%" /></label>
            <label>Likely timing<input defaultValue="Before 10 PM" /></label>
            <label>Wind<input defaultValue="W 4–8 mph" /></label>
            <label>Confidence<select defaultValue="moderate"><option value="low">Low</option><option value="moderate">Moderate</option><option value="high">High</option></select></label>
            <label className="wide-field">Hazards<input defaultValue="Patchy fog near daybreak" /></label>
            <label className="wide-field">Night reasoning<textarea defaultValue="Convection should diminish after sunset as instability weakens. Residual low-level moisture may support patchy fog in sheltered valleys toward morning." /></label>
          </div></fieldset>
          <div className="form-actions"><span>{saveMessage}</span><button type="submit">Save forecast draft</button></div>
        </form>
      </section>}

      {activeSection === "verify" && <section className="workspace-card">
        <div className="section-heading"><div><h2>Verification · Monday, July 13</h2><p>Asheville Regional Airport</p></div><span>3 / 4 metrics verified</span></div>
        <div className="verification-grid"><div>
          <h3>Day · 7 AM–7 PM</h3><table><thead><tr><th>Metric</th><th>Your forecast</th><th>NBM</th><th>Observed</th></tr></thead><tbody><tr><td>High temperature</td><td>85°F</td><td>83°F</td><td>84°F</td></tr><tr><td>Rain chance</td><td>70%</td><td>62%</td><td>Rain observed</td></tr><tr><td>Rain timing</td><td>4–7 PM</td><td>3–8 PM</td><td>5:12 PM</td></tr></tbody></table>
          <h3>Night · 7 PM–7 AM</h3><table><thead><tr><th>Metric</th><th>Your forecast</th><th>NBM</th><th>Observed</th></tr></thead><tbody><tr><td>Low temperature</td><td>68°F</td><td>67°F</td><td>67°F</td></tr><tr><td>Rain chance</td><td>20%</td><td>24%</td><td>Dry after 8 PM</td></tr><tr><td>Fog risk</td><td>Patchy</td><td>Patchy</td><td>Patchy fog 5–7 AM</td></tr></tbody></table>
        </div><aside className="history"><h3>Forecast history</h3><button>Jul 13 · Day + night</button><button>Jul 12 · Day + night</button><button>Jul 11 · Day + night</button><p>Future versions will reopen each archived forecast and its saved data evidence.</p></aside></div>
      </section>}
    </main>
  );
}
