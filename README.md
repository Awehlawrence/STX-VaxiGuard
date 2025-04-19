

## README – STX-VaxVaccine Tracking Smart Contract

### Overview
This Clarity smart contract provides a secure and auditable system for managing vaccine distribution, administration, and tracking on the Stacks blockchain. It ensures accountability, efficient logistics, and accurate patient vaccination records, while adhering to stringent medical and operational standards.

---

###  Features

- **Ownership Management**
  - Only the contract owner can register healthcare providers and storage facilities.
  - Ownership can be transferred securely to another principal.

- **Healthcare Provider Registration**
  - Register verified healthcare providers with role, facility, and credential expiration.

- **Storage Facility Registration**
  - Register vaccine storage locations with capacity and temperature tracking.

- **Vaccine Batch Registration & Management**
  - Register vaccine batches with manufacturer details, expiry, and storage metadata.
  - Track batch status and flag compromised doses via temperature breaches.

- **Patient Vaccination Records**
  - Maintain a full history of administered vaccines for each patient.
  - Enforce rules like dose intervals, max dose limits, and expiry validation.

- **Validation & Error Handling**
  - Extensive checks for string lengths, future dates, capacity limits, and temperature ranges.
  - Standardized error codes for consistent and predictable failure states.

---

### 📚 Data Structures

#### Vaccine Batches
```clarity
vaccine-batches: {
  vaccine-manufacturer, vaccine-name,
  manufacturing-date, batch-expiry-date,
  available-doses, storage-temperature,
  batch-status, temperature-breach-count,
  storage-facility, additional-batch-notes
}
```

#### Patient Records
```clarity
patient-vaccination-records: {
  vaccination-history: [10 items max],
  completed-doses, reported-side-effects,
  vaccination-exemption-reason
}
```

#### Healthcare Providers
```clarity
healthcare-providers: {
  provider-role, healthcare-facility,
  credentials-expiry-date
}
```

#### Storage Facilities
```clarity
vaccine-storage-facilities: {
  facility-address, maximum-storage-capacity,
  current-inventory, facility-temperature-history
}
```

---

### 🔐 Access Control

| Function | Permission |
|---------|------------|
| `register-healthcare-provider` | Owner Only |
| `register-storage-facility` | Owner Only |
| `register-vaccine-batch` | Authorized Providers |
| `update-batch-status` | Authorized Providers |
| `record-temperature-breach` | Authorized Providers |
| `record-vaccination` | Authorized Providers |

---

### 🔎 Utility Functions

- `validate-string-*`: Ensures string fields meet minimum length requirements.
- `validate-future-date`: Confirms a given date is after the current block.
- `validate-storage-capacity`: Verifies positive storage size.
- `is-provider-authorized`: Checks provider validity and credential status.
- `is-vaccine-batch-valid`: Returns `true` only if batch is active, unexpired, and uncompromised.

---

### 🔄 Read-Only Functions

- `get-vaccine-contract-owner`
- `get-vaccine-batch-info`
- `get-patient-vaccination-record`
- `get-storage-facility-info`
- `is-vaccine-batch-valid`

---

### ⚠️ Error Codes

| Error | Meaning |
|-------|---------|
| `u100` | Not authorized |
| `u101` | Invalid batch |
| `u102` | Batch already exists |
| `u103` | Batch not found |
| `u104` | Insufficient vaccine quantity |
| `u105` | Invalid patient ID |
| `u106` | Patient already vaccinated |
| `u107` | Temperature out of range |
| `u108` | Vaccine batch expired |
| `u109` | Invalid vaccination location |
| `u110` | Maximum doses reached |
| `u111` | Minimum dose interval not met |
| `u112` | Contract owner only |
| `u113` | Invalid input |
| `u114` | Invalid expiry date |
| `u115` | Invalid storage capacity |

---

### 🛠 Setup & Deployment

1. Deploy this contract using [Clarinet](https://docs.stacks.co/docs/clarity/clarinet/overview/).
2. Use `transfer-contract-ownership` to assign a specific deployer/admin.
3. Register healthcare providers and facilities before any vaccination operations.

---
