import { format } from 'date-fns';
import { es } from 'date-fns/locale';
import { Client, Event, User } from '../types/entities';

type EventWithClient = Event & {
  client?: Client | null;
};

type UserProfile = User | null;

export const CONTRACT_TEMPLATE_TOKENS = [
  'provider_name',
  'provider_business_name',
  'provider_email',
  'current_date',
  'event_date',
  'event_start_time',
  'event_end_time',
  'event_time_range',
  'event_service_type',
  'event_num_people',
  'event_location',
  'event_city',
  'event_total_amount',
  'event_deposit_percent',
  'event_refund_percent',
  'event_cancellation_days',
  'client_name',
  'client_phone',
  'client_email',
  'client_address',
  'client_city',
  'contract_city',
] as const;

type ContractToken = (typeof CONTRACT_TEMPLATE_TOKENS)[number];

export const DEFAULT_CONTRACT_TEMPLATE = `1. El Proveedor es una empresa dedicada a [event_service_type], [provider_business_name], y cuenta con la capacidad para la prestación de dicho servicio.
2. El Cliente: [client_name] desea contratar los servicios del Proveedor para el evento que se llevará a cabo el [event_date], en [event_location].

Por lo tanto, las partes acuerdan las siguientes cláusulas:

CLÁUSULAS:
Primera. Objeto del Contrato
El Proveedor se compromete a prestar los servicios de [event_service_type] para [event_num_people] personas.

Segunda. Horarios de Servicio
El servicio será prestado en el evento en un horario de [event_time_range].

Tercera. Costo Total
El costo total del servicio contratado será de [event_total_amount].

Cuarta. Condiciones de Pago
El Cliente deberá cubrir un anticipo del [event_deposit_percent]% para reservar la fecha. El resto deberá liquidarse antes del inicio del evento.

Quinta. Condiciones del Servicio
El Cliente se compromete a facilitar un espacio adecuado para la instalación del equipo necesario, que deberá contar con una superficie plana y conexión de luz.

Sexta. Cancelaciones y Reembolsos
En caso de cancelación por parte del Cliente con menos de [event_cancellation_days] días de anticipación, no se realizará reembolso del apartado.
Cuando la cancelación se realice dentro del plazo permitido, se reembolsará el [event_refund_percent]% del apartado.

Octava. Jurisdicción
Para cualquier disputa derivada de este contrato, las partes se someten a la jurisdicción de los tribunales competentes de [contract_city].

Novena. Modificaciones
Cualquier modificación a este contrato deberá ser acordada por ambas partes por escrito.

Firmas:
Proveedor: [provider_name]
Cliente: [client_name]`;

const TOKEN_REGEX = /\[([a-z_]+)\]/g;

export class ContractTemplateError extends Error {
  invalidTokens: string[];
  missingTokens: string[];

  constructor(message: string, invalidTokens: string[] = [], missingTokens: string[] = []) {
    super(message);
    this.name = 'ContractTemplateError';
    this.invalidTokens = invalidTokens;
    this.missingTokens = missingTokens;
  }
}

const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
  }).format(amount);
};

const asText = (value: unknown): string | undefined => {
  if (value === null || value === undefined) return undefined;
  const text = String(value).trim();
  return text.length > 0 ? text : undefined;
};

const getEventDateText = (eventDate: string): string => {
  const parsed = new Date(eventDate);
  if (Number.isNaN(parsed.getTime())) return eventDate;
  const userTimezoneOffset = parsed.getTimezoneOffset() * 60000;
  const localDate = new Date(parsed.getTime() + userTimezoneOffset);
  return format(localDate, "d 'de' MMMM 'de' yyyy", { locale: es });
};

const getCurrentDateText = (): string => {
  return format(new Date(), "d 'de' MMMM 'de' yyyy", { locale: es });
};

export const validateContractTemplate = (template: string) => {
  const foundTokens = Array.from(template.matchAll(TOKEN_REGEX)).map((match) => match[1]);
  const invalidTokens = Array.from(
    new Set(foundTokens.filter((token) => !CONTRACT_TEMPLATE_TOKENS.includes(token as ContractToken))),
  );

  return {
    invalidTokens,
  };
};

const buildTokenValues = (event: EventWithClient, profile: UserProfile): Record<ContractToken, string | undefined> => {
  const providerName = asText(profile?.name);
  const providerBusinessName = asText(profile?.business_name) || providerName;
  const eventStart = asText(event.start_time);
  const eventEnd = asText(event.end_time);

  return {
    provider_name: providerName,
    provider_business_name: providerBusinessName,
    provider_email: asText(profile?.email),
    current_date: getCurrentDateText(),
    event_date: getEventDateText(event.event_date),
    event_start_time: eventStart,
    event_end_time: eventEnd,
    event_time_range: eventStart && eventEnd ? `${eventStart} - ${eventEnd}` : eventStart || eventEnd,
    event_service_type: asText(event.service_type),
    event_num_people: asText(event.num_people),
    event_location: asText(event.location),
    event_city: asText(event.city),
    event_total_amount: formatCurrency(event.total_amount || 0),
    event_deposit_percent: asText(event.deposit_percent ?? profile?.default_deposit_percent),
    event_refund_percent: asText(event.refund_percent ?? profile?.default_refund_percent),
    event_cancellation_days: asText(event.cancellation_days ?? profile?.default_cancellation_days),
    client_name: asText(event.client?.name),
    client_phone: asText(event.client?.phone),
    client_email: asText(event.client?.email),
    client_address: asText(event.client?.address),
    client_city: asText(event.client?.city),
    contract_city: asText(event.city) || asText(event.client?.city),
  };
};

export const renderContractTemplate = ({
  event,
  profile,
  template,
  strict = true,
}: {
  event: EventWithClient;
  profile: UserProfile;
  template?: string | null;
  strict?: boolean;
}) => {
  const sourceTemplate = asText(template) || DEFAULT_CONTRACT_TEMPLATE;
  const { invalidTokens } = validateContractTemplate(sourceTemplate);
  if (invalidTokens.length > 0) {
    throw new ContractTemplateError('La plantilla contiene placeholders no soportados.', invalidTokens, []);
  }

  const values = buildTokenValues(event, profile);
  const missingTokens = new Set<string>();

  const rendered = sourceTemplate.replace(TOKEN_REGEX, (_, token: string) => {
    const value = values[token as ContractToken];
    if (!value) {
      missingTokens.add(token);
      return `[${token}]`;
    }
    return value;
  });

  if (strict && missingTokens.size > 0) {
    throw new ContractTemplateError('Faltan datos para completar la plantilla del contrato.', [], Array.from(missingTokens));
  }

  return rendered;
};
