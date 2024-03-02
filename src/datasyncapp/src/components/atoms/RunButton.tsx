'use client';
import { runWebhook } from '@/app/actions/runWebhook';
import { useToast } from '@chakra-ui/react';
import { mdiPlayOutline } from '@mdi/js';
import { useMutation } from '@tanstack/react-query';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import { useFormState } from 'react-dom';
import { mutateAuditRecord } from '../molecules/JobsList/audit';
import { SubmitButton } from './SubmitButton';

const initialState = {
  isError: false,
  message: null,
};

type RunButtonProps = {
  webhook: string;
  webhookItemId: string;
};

export const RunButton = ({ webhook, webhookItemId }: RunButtonProps) => {
  const [state, formAction] = useFormState(runWebhook, initialState);
  const toast = useToast();
  const router = useRouter();

  const { mutate } = useMutation({
    mutationFn: mutateAuditRecord,
    onSuccess: () => {
      // Invalidate and refetch
      // queryClient.invalidateQueries({ queryKey: [''] })
      router.refresh();
    },
  });

  useEffect(() => {
    if (!!toast && !!state.message) {
      const message = state.isError ? state.message : 'Webhook triggered';
      toast({
        description: message,
        status: state.isError ? 'error' : 'success',
        isClosable: true,
        duration: null,
      });
      if (!!webhookItemId) {
        mutate({
          lastMessage: `${state.isError ? 'ERROR' : 'SUCCESS'} ${message}`,
          lastRun: new Date().toString(),
          webhookItemId: webhookItemId,
        });
      }
    }
  }, [mutate, state, toast, webhookItemId]);

  return (
    <form action={formAction}>
      <input type="hidden" name="webhook" value={webhook} />
      <SubmitButton icon={mdiPlayOutline} tooltip="Run!" />
    </form>
  );
};
