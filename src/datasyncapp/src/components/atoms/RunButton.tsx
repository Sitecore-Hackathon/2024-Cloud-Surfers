'use client';
import { runWebhook } from '@/app/actions/runWebhook';
import { useToast } from '@chakra-ui/react';
import { mdiPlayOutline } from '@mdi/js';
import { useEffect } from 'react';
import { useFormState } from 'react-dom';
import { SubmitButton } from './SubmitButton';

const initialState = {
  isError: false,
  message: null,
};

type RunButtonProps = {
  webhook: string;
};

export const RunButton = ({ webhook }: RunButtonProps) => {
  const [state, formAction] = useFormState(runWebhook, initialState);
  const toast = useToast();

  useEffect(() => {
    if (!!toast && !!state.message) {
      toast({
        description: state.message,
        status: state.isError ? 'error' : 'success',
        isClosable: true,
        duration: null,
      });
    }
  }, [state, toast]);

  return (
    <form action={formAction}>
      <input type="hidden" name="webhook" value={webhook} />
      <SubmitButton icon={mdiPlayOutline} tooltip="Run!" />
    </form>
  );
};
