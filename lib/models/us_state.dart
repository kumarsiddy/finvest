class USState {
  final String code;
  final String name;

  const USState(this.code, this.name);

  static const List<USState> allStates = [
    USState('AL', 'Alabama'),
    USState('AK', 'Alaska'),
    USState('AZ', 'Arizona'),
    USState('AR', 'Arkansas'),
    USState('CA', 'California'),
    USState('CO', 'Colorado'),
    USState('CT', 'Connecticut'),
    USState('DE', 'Delaware'),
    USState('FL', 'Florida'),
    USState('GA', 'Georgia'),
    USState('HI', 'Hawaii'),
    USState('ID', 'Idaho'),
    USState('IL', 'Illinois'),
    USState('IN', 'Indiana'),
    USState('IA', 'Iowa'),
    USState('KS', 'Kansas'),
    USState('KY', 'Kentucky'),
    USState('LA', 'Louisiana'),
    USState('ME', 'Maine'),
    USState('MD', 'Maryland'),
    USState('MA', 'Massachusetts'),
    USState('MI', 'Michigan'),
    USState('MN', 'Minnesota'),
    USState('MS', 'Mississippi'),
    USState('MO', 'Missouri'),
    USState('MT', 'Montana'),
    USState('NE', 'Nebraska'),
    USState('NV', 'Nevada'),
    USState('NH', 'New Hampshire'),
    USState('NJ', 'New Jersey'),
    USState('NM', 'New Mexico'),
    USState('NY', 'New York'),
    USState('NC', 'North Carolina'),
    USState('ND', 'North Dakota'),
    USState('OH', 'Ohio'),
    USState('OK', 'Oklahoma'),
    USState('OR', 'Oregon'),
    USState('PA', 'Pennsylvania'),
    USState('RI', 'Rhode Island'),
    USState('SC', 'South Carolina'),
    USState('SD', 'South Dakota'),
    USState('TN', 'Tennessee'),
    USState('TX', 'Texas'),
    USState('UT', 'Utah'),
    USState('VT', 'Vermont'),
    USState('VA', 'Virginia'),
    USState('WA', 'Washington'),
    USState('WV', 'West Virginia'),
    USState('WI', 'Wisconsin'),
    USState('WY', 'Wyoming'),
  ];

  static USState? findByCode(String code) {
    try {
      return allStates.singleWhere((element) => element.code == code);
    } catch (e) {
      return null;
    }
  }
}

// Example usage:
// USState state = USState.allStates.firstWhere((state) => state.code == 'CA');
// print(state.name);  // Outputs: California
