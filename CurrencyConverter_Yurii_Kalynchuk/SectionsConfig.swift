//
//  SectionsConfig.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import Foundation

let sectioinConfigurationJson = """
{
  "sections": [
    {
      "sectionType": {
        "balance": {
          
        }
      },
      "sectionTitle": "my_balances",
      "cells": [
        {
          "cellType": {
            "balance": {
              "_0": [
                
              ]
            }
          }
        }
      ]
    },
    {
      "sectionType": {
        "exchange": {
          
        }
      },
      "sectionTitle": "currency_exchange",
      "cells": [
        {
          "cellType": {
            "exchange": {
              "_0": {
                "type": {
                  "sell": {
                    
                  }
                },
                "currencies": [
                  
                ],
                "currencyType": ""
              }
            }
          }
        },
        {
          "cellType": {
            "exchange": {
              "_0": {
                "currencyType": "",
                "amount": 0,
                "currencies": [
                  
                ],
                "type": {
                  "receive": {
                    
                  }
                }
              }
            }
          }
        }
      ]
    }
  ]
}
"""

