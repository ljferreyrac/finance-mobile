const String baseUrl = 'https://finance-backend-leojfc.up.railway.app';

const String apiV1 = '$baseUrl/api/v1';

const List<String> supportedCurrencies = ['PEN', 'USD'];

// Mirrors the bank list in CLAUDE.md; keep both in sync.
const List<String> supportedBanks = [
  'BCP',
  'BBVA',
  'Interbank',
  'Scotiabank',
  'Yape',
  'Plin',
  'Otro',
];

const int defaultPageSize = 20;
