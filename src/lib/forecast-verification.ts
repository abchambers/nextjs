/** Shared verification contract for browser collection, cron jobs, and future sensor ingestion. */
export type ForecastPeriodActual = {
  observationCount: number;
  highF: number | null;
  lowF: number | null;
  maxWindMph: number | null;
  precipitationObserved: boolean;
  conditions: string[];
  complete: boolean;
};

/**
 * Current transparent scoring rule: temperature accuracy supplies 70 points
 * and the precipitation-occurrence call supplies 30. Keep this pure so the
 * same input creates the same score whether it came from NWS or owned sensors.
 */
export function automaticForecastScore(forecastTemperature: string, rainChance: string, actual: ForecastPeriodActual, useHigh: boolean) {
  const predictedTemperature = Number.parseFloat(forecastTemperature);
  const observedTemperature = useHigh ? actual.highF : actual.lowF;
  if (!actual.observationCount || !Number.isFinite(predictedTemperature) || observedTemperature === null) return null;
  const temperaturePoints = Math.max(0, 70 - Math.abs(predictedTemperature - observedTemperature) * 10);
  const precipitationPoints = (Number.parseFloat(rainChance) >= 50) === actual.precipitationObserved ? 30 : 0;
  return Math.round(temperaturePoints + precipitationPoints);
}
