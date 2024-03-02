import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
import { Providers } from './providers';
import { Shell } from './shell';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'XM Cloud Operator Hub',
  description: 'XM Cloud Module',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Providers>
          <Shell>{children}</Shell>
        </Providers>
      </body>
    </html>
  );
}
