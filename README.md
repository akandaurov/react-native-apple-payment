# react-native-apple-payment

Apple Pay implementation for React Native (Only IOS)

<div style="display: flex;">
    <img style="margin-right: 20px" src="images/img1.png" width="250" height="530" alt="img1" />
    <img style="margin-right: 20px" src="images/img2.png" width="250" height="530" alt="img2" />
    <img style="margin-right: 20px" src="images/img3.png" width="250" height="530" alt="img3" />
</div>

## Installation

```sh
yarn add react-native-apple-payment

cd ios && pod install
```

## Usage

### Types

```ts

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

```

### Code
```ts

import ApplePay, { MethodData, DetailsData, ApplePayResponse } from "react-native-apple-payment";

const payment = new ApplePay(method as MethodData, details as DetailsData);

const canMakePayment: boolean = await payment.canMakePayments()

const paymentResponse: ApplePayResponse = await payment.initApplePay()

```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
