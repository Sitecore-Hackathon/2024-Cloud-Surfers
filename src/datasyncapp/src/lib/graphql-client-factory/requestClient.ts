import { GraphQLClient } from 'graphql-request';
import { IncomingMessage, ServerResponse } from 'http';

let requestClient: GraphQLClient;

export type ResolverContext = {
  req?: IncomingMessage;
  res?: ServerResponse;
};

// function createRequestClient(context?: ResolverContext) {
function createRequestClient() {
  const graphQLClient = new GraphQLClient(process.env.GRAPHQL_ENDPOINT!, {
    headers: { Authorization: process.env.XM_Cloud_Access_Token! },
  });
  return graphQLClient;
}

// export function initRequestClient(context?: ResolverContext) {
export function initRequestClient() {
  // Pages with Next.js data fetching methods, like `getStaticProps`, can send
  // a custom context which will be used by `SchemaLink` to server render pages
  const _client = requestClient ?? createRequestClient(); // context

  // For SSG and SSR always create a new Client
  if (typeof window === 'undefined') return _client;

  // Create the client once in the client
  if (!requestClient) requestClient = _client;

  return _client;
}
