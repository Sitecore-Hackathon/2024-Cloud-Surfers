import { runWebhook } from '@/app/actions/runWebhook';
import { mdiPlayOutline } from '@mdi/js';
import { SubmitButton } from './SubmitButton';

const initialState = {
  webhook: null,
};

type RunButtonProps = {
  webhook: string;
};

export const RunButton = ({ webhook }: RunButtonProps) => {
  return (
    <form action={runWebhook}>
      <input type="hidden" name="webhook" value={webhook} />
      <SubmitButton icon={mdiPlayOutline} tooltip="Run!" />
    </form>
  );
};
