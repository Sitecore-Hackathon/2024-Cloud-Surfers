'use server';
import { z } from 'zod';

// Server Action
export async function runWebhook(formData: FormData) {
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
    return { message: 'No good' };
  }

  // Parse input
  const data = schema.parse({
    webhook: formData.get('webhook'),
  });

  // Invoke webhook
  const url = data.webhook;
  try {
    const res = await fetch(url, { cache: 'no-store' });
    const json = res.json();
    console.log('WEBHOOK', url, res.status, json);

    // revalidatePath('/')

    return { message: 'Did stuff' };
  } catch (e) {
    return { message: 'No good' };
  }
}
