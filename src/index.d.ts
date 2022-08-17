declare module 'react-native-apple-payment' {
  type Network = 'Visa' | 'MasterCard' | 'AmEx';

  export type SupportedNetworks = Network[];

  export interface MethodData {
    countryCode: string;
    currencyCode: string;
    supportedNetworks: SupportedNetworks;
    merchantIdentifier: string;
  }

  export interface Detail {
    label: string;
    amount: number;
  }

  export interface DetailsData {
    items?: Detail[];
    total: Detail;
  }

  export type ApplePayResponse = {
    paymentData: string;
    paymentMethod: {
      displayName: string;
      network: string;
      type: string;
    };
  };

  export default class ApplePay {
    constructor(method: MethodData, details: DetailsData);
    initApplePay(): Promise<ApplePayResponse>;
    canMakePayments(): Promise<boolean>;
  }
}
