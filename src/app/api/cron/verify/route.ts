import { NextRequest, NextResponse } from "next/server";

type Period = { id: string; valid_date: string; period: "day" | "night"; forecast_data: { highLow?: string; rainChance?: string } };
type Run = { id: string; forecast_periods: Period[] };
type ActualPeriod = { complete: boolean; highF: number | null; lowF: number | null; precipitationObserved: boolean };

function score(forecastTemperature: string | undefined, rainChance: string | undefined, actual: ActualPeriod, useHigh: boolean) {
  const predicted = Number.parseFloat(forecastTemperature ?? "");
  const observed = useHigh ? actual.highF : actual.lowF;
  if (!actual.complete || !Number.isFinite(predicted) || observed === null) return null;
  const temperaturePoints = Math.max(0, 70 - Math.abs(predicted - observed) * 10);
  const precipitationPoints = (Number.parseFloat(rainChance ?? "") >= 50) === actual.precipitationObserved ? 30 : 0;
  return Math.round(temperaturePoints + precipitationPoints);
}

export async function GET(request: NextRequest) {
  const cronSecret = process.env.CRON_SECRET;
  if (!cronSecret || request.headers.get("authorization") !== `Bearer ${cronSecret}`) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!supabaseUrl || !serviceKey) return NextResponse.json({ error: "Scheduler storage is not configured." }, { status: 500 });
  const headers = { apikey: serviceKey, Authorization: `Bearer ${serviceKey}`, "Content-Type": "application/json", Prefer: "resolution=merge-duplicates" };
  try {
    const runsResponse = await fetch(`${supabaseUrl}/rest/v1/forecast_runs?select=id,forecast_periods(id,valid_date,period,forecast_data)&status=eq.submitted`, { headers, cache: "no-store" });
    if (!runsResponse.ok) throw new Error("Unable to load submitted forecast runs.");
    const runs = await runsResponse.json() as Run[];
    const dates = [...new Set(runs.flatMap((run) => run.forecast_periods.map((period) => period.valid_date)))];
    const actuals = new Map<string, { day: ActualPeriod; night: ActualPeriod }>();
    await Promise.all(dates.map(async (date) => {
      const response = await fetch(new URL(`/api/verify?date=${date}`, request.url), { cache: "no-store" });
      if (response.ok) actuals.set(date, await response.json());
    }));
    let saved = 0;
    for (const run of runs) {
      let allComplete = run.forecast_periods.length > 0;
      for (const period of run.forecast_periods) {
        const actual = actuals.get(period.valid_date)?.[period.period];
        if (!actual?.complete) { allComplete = false; continue; }
        const automaticScore = score(period.forecast_data.highLow, period.forecast_data.rainChance, actual, period.period === "day");
        const response = await fetch(`${supabaseUrl}/rest/v1/forecast_verifications?on_conflict=forecast_period_id`, { method: "POST", headers, body: JSON.stringify({ forecast_period_id: period.id, observed_data: actual, score_data: { automaticScore, method: "temperature (70) + precipitation occurrence (30)", automatedAt: new Date().toISOString() } }) });
        if (response.ok) saved += 1;
      }
      if (allComplete) await fetch(`${supabaseUrl}/rest/v1/forecast_runs?id=eq.${run.id}`, { method: "PATCH", headers, body: JSON.stringify({ status: "verified" }) });
    }
    return NextResponse.json({ checkedRuns: runs.length, savedPeriods: saved });
  } catch (error) {
    return NextResponse.json({ error: error instanceof Error ? error.message : "Automated verification failed." }, { status: 500 });
  }
}
