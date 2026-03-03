class ShakeReporterEndpoints {
  const ShakeReporterEndpoints._();

  static const String apiLink = String.fromEnvironment(
    'API_LINK',
    defaultValue: 'https://staging2.tagaddod.com/graphql',
  );

  static const String linearApiLink = String.fromEnvironment(
    'LINEAR_LINK',
    defaultValue: 'https://api.linear.app/graphql',
  );

  static const String linearToken = String.fromEnvironment(
    'LINEAR_TOKEN',
    defaultValue: '',
  );

  static const String linearTeamId = String.fromEnvironment(
    'LINEAR_TEAM_ID',
    defaultValue: '',
  );

  static const String linearProjectId = String.fromEnvironment(
    'LINEAR_PROJECT_ID',
    defaultValue: '',
  );
}
