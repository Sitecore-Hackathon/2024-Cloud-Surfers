'use client';
import { Icon, IconButton, Tooltip } from '@chakra-ui/react';
import { useFormStatus } from 'react-dom';

type SubmitButtonProps = {
  icon: string;
  tooltip: string;
};

export const SubmitButton = ({ icon, tooltip }: SubmitButtonProps) => {
  const { pending } = useFormStatus();
  return (
    <Tooltip label="Run!">
      <IconButton
        icon={
          <Icon>
            <path d={icon} />
          </Icon>
        }
        type="submit"
        size="lg"
        isActive
        isLoading={pending}
        colorScheme="success"
        aria-label={tooltip}
      />
    </Tooltip>
  );
};
