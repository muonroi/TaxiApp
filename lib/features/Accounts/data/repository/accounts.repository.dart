import 'package:muonroi/core/services/api_account_provider.dart';
import 'package:muonroi/features/accounts/data/models/models.account.signin.dart';

class AccountRepository {
  final String username;
  final String password;
  final _provider = AccountsProvider();

  AccountRepository(this.username, this.password);

  Future<AccountSignInModel> signIn() => _provider.signIn(username, password);
}

class NetworkError extends Error {}
