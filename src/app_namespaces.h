#pragma once

#include <QStringList>

namespace App {

    enum Tables: int {
        PARTNERS = 1,
        PARTNERS_BANK = 2,
        PARTNERS_PERSON = 3,
        PARTNERS_DOC = 4,
        CONTRACTS = 5,
        AMENDMENTS = 6,
        DOCUMENTS = 7,
        PAYMENTS = 8,
        CURRENCY = 9
    };

    enum Params: int {
        ONLY_FILE = 1
    };

    enum DocTypes : int {
        AMENDMENT = 0,
        INVOICE = 1,
        PAYMENT = 2,
        CORRESPONDENCE = 3,
        ESTIMATE = 4,
        GOODS = 5,
        ACTS = 6,
        OTHER = 7
    };

    enum Status: int {
        ACTIVE = 1,
        ABORTED = 2,
        COMPLETED = 3,
        ARCHIVE = 4
    };

    enum Notes : int {
        SUCCESS = 1,
        ERROR = 2,
        NOTIFY = 3,
    };

    enum PayStatus : int {
        NOT_PAID = 0,
        PARTIALLY_PAID = 1,
        PAID = 2,
    };
}

