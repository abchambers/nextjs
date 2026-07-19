"use client";

import { useState } from "react";

type DataPanel = "nbm" | "sounding" | "models";

export default function Home() {
  const [dataPanel, setDataPanel] = useState<DataPanel>("nbm");
  const [radarExpanded, setRadarExpanded] = useState(false);

  return (
    <main className={radarExpanded ? "app radar-expanded" : "app"}>
      <header className="header">
        <div><p className="eyebrow">Human-first forecasting workspace</p><h1>The Weather Desk</h1></div>
        <div className="location">Asheville, NC <span>Student workspace</span></div>
      </header>

      <nav aria-label="Main navigation" className="navigation">
        <button className="active">Dashboard</button><button>Forecast</button><button>Verify</button>
      </nav>

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
    </main>
  );
}
