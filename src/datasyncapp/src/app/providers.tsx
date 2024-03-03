'use client';

import TanstackQueryProvider from '@/lib/tanstackQuery/TanstackQueryProvider';
import { ChakraProvider } from '@chakra-ui/react';
import sitecoreTheme, { toastOptions } from '@sitecore/blok-theme';
import { Session } from 'next-auth';
import { SessionProvider } from 'next-auth/react';

type ProviderProps = {
  session?: Session | null;
  children: React.ReactElement;
};

export function Providers({ children, session }: ProviderProps) {
  return (
    <ChakraProvider theme={sitecoreTheme} toastOptions={toastOptions}>
      <SessionProvider
        // Provider options are not required but can be useful in situations where
        // you have a short session maxAge time. Shown here with default values.
        session={session}
      >
        <TanstackQueryProvider>{children}</TanstackQueryProvider>
      </SessionProvider>
    </ChakraProvider>
  );
}
