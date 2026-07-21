import type { Metadata } from "next";
import "./globals.css";
import "./verify-overrides.css";

export const metadata: Metadata = {
  title: "The Weather Desk",
  description: "A human-first weather forecasting workspace.",
  icons: {
    icon: "/icon.svg",
  },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}
