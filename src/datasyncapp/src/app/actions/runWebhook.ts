'use server';
import { z } from 'zod';

// Server Action
export async function runWebhook(prevState: any, formData: FormData) {
  // 'use server';
  console.log('Hellooo!');

  // Define schema
  const schema = z.object({
    webhook: z.string({ invalid_type_error: 'Invalid webhook' }).min(1),
  });

  // Validate input
  const validatedFields = schema.safeParse({
    webhook: formData.get('webhook'),
  });
  if (!validatedFields.success) {
    return { isError: true, message: 'Invalue input' };
  }

  // Parse input
  const data = schema.parse({
    webhook: formData.get('webhook'),
  });

  // Invoke webhook
  const url = data.webhook;
  try {
    const res = await fetch(url, { cache: 'no-store' });
    const text = await res.text();
    console.log('WEBHOOK', url, res.status, text);

    // revalidatePath('/')

    return { isError: res.status >= 400, message: text };
  } catch (e) {
    return { isError: true, message: 'No good' };
  }
}
