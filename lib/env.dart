class Env {
  final String name;

  const Env(this.name);
}

const uat = 'uat';
const dev = 'dev';
const prod = 'prod';
const test = 'test';

const List<String> injectionEnv = [uat, prod];
