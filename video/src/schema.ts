import { z } from 'zod';

export const ClientTutorialSchema = z.object({
  clientName: z.string().default('María García López'),
  clientPhone: z.string().default('55 1234 5678'),
  clientEmail: z.string().default('maria@correo.com'),
});

export type ClientTutorialProps = z.infer<typeof ClientTutorialSchema>;
