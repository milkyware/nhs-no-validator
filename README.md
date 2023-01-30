# NHS No Validator

- [NHS No Validator](#nhs-no-validator)
  - [Overview](#overview)
  - [Docker](#docker)
  - [References](#references)

## Overview

This is a simple microservice to perform initial validation on NHS numbers. Validating NHS numbers is achieved by performing a **Modulus 11** based check on the first 9 digits with the final, check digit. More detail can be found on **[NHS Data Dictionary](https://www.datadictionary.nhs.uk/attributes/nhs_number.html)**, but a summary of the steps involed are below:

1. Multiply each of the first 9 digits by a declining weighting factor starting at 10
2. Sum together the totals from the previous step
3. Calculate the modulo remainder of the total by 11
4. Subtract the remainder from 11 to give the expected check digit
   - If the result is 10, the NHS number is not valid. If 11, the expected check digit becomes 0
5. Compare the expected check digit with the final digit of the NHS number

## Docker

Below is an example command of running the API in a docker container locally

``` bash
docker run -d -p 8080:80 milkyware/nhs-no-validator:latest
```

## References

- [NHS No Validation Algorithm](https://www.datadictionary.nhs.uk/attributes/nhs_number.html)