'use server';

import { initRequestClient } from '@/lib/graphql-client-factory/requestClient';
import { AUDIT_WEBHOOK } from './graphql';
import { TAuditResult } from './type';

type AuditHookInputs = {
  webhookItemId: string;
  lastRun: string;
  lastMessage: string;
};

/*
 * Update Audit refcord
 */
export async function mutateAuditRecord(inputs: AuditHookInputs): Promise<TAuditResult> {
  /* This uses Sitecore GraphQLClient wich has built-in debug logging */
  const client = initRequestClient();

  return client.request<TAuditResult>(AUDIT_WEBHOOK, { ...inputs });
}
