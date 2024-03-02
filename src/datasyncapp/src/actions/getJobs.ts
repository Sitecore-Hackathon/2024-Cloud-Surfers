import { fetchDataSyncJobs } from '@/components/molecules/JobsList/fetch';

export default async function getJobs() {
  'use server';
  return fetchDataSyncJobs();
}
