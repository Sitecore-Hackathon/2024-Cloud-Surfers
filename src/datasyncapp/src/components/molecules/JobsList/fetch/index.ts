import { initRequestClient } from '@/lib/graphql-client-factory/requestClient';
import { GET_ALL_DATA_SYNC_JOBS } from './graphql';
import { TJobQueryResult } from './type';

/*
 * Fetch jobs
 */
export function fetchDataSyncJobs(): Promise<TJobQueryResult> {
  /* This uses Sitecore GraphQLClient wich has built-in debug logging */
  const client = initRequestClient();

  return client.request<TJobQueryResult>(GET_ALL_DATA_SYNC_JOBS);
}

export const qKeyJobs = 'dsJobs';
