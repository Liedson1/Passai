import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:passai/core/constants/app_constants.dart';
import 'package:passai/core/theme/app_colors.dart';
import 'package:passai/core/theme/app_text_styles.dart';
import 'package:passai/domain/repositories/auth_repository.dart';
import 'package:passai/presentation/providers/auth_provider.dart';
import 'package:passai/presentation/widgets/auth/auth_hero_banner.dart';
import 'package:passai/presentation/widgets/auth/auth_input_field.dart';

/// Tela de cadastro do Passaí.
///
/// Segue Clean Architecture + SOLID:
/// - Nenhuma lógica de negócio aqui (SRP)
/// - Depende de [SignUpNotifier] via abstração Riverpod (DIP)
/// - UI apenas observa estado e delega ações ao notifier
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// Delega o cadastro ao [SignUpNotifier] — zero lógica aqui.
  Future<void> _onCriarConta() async {
    setState(() => _errorMessage = null);
    await ref.read(signUpNotifierProvider.notifier).cadastro(
          nome: _nomeController.text,
          email: _emailController.text,
          telefone: _telefoneController.text,
          senha: _senhaController.text,
        );
  }

  /// Observa o estado após mudança e reage (navegação ou erro).
  void _onStateChanged(AsyncValue<dynamic>? previous, AsyncValue<dynamic> next) {
    if (!mounted) return;

    next.whenOrNull(
      data: (user) {
        if (user != null) {
          // Cadastro concluído — vai para home
          context.go(AppRoutes.home);
        }
      },
      error: (erro, _) {
        final mensagem = erro is AuthException
            ? erro.mensagem
            : 'Ocorreu um erro inesperado.';
        setState(() => _errorMessage = mensagem);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(signUpNotifierProvider, _onStateChanged);

    final isLoading = ref.watch(signUpNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeroBanner(
              titulo: 'Crie sua conta',
              subtitulo: 'Consulte horários de vans intermunicipais no Sertão',
            ),
            _RegisterCard(
              nomeController: _nomeController,
              emailController: _emailController,
              telefoneController: _telefoneController,
              senhaController: _senhaController,
              senhaVisivel: _senhaVisivel,
              isLoading: isLoading,
              errorMessage: _errorMessage,
              onToggleSenha: () =>
                  setState(() => _senhaVisivel = !_senhaVisivel),
              onCriarConta: _onCriarConta,
            ),
            const SizedBox(height: 16),
            const _TermsText(),
            const SizedBox(height: 20),
            const _LoginTrigger(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de cadastro — UI pura, sem lógica de negócio (SRP)
// ---------------------------------------------------------------------------
class _RegisterCard extends StatelessWidget {
  const _RegisterCard({
    required this.nomeController,
    required this.emailController,
    required this.telefoneController,
    required this.senhaController,
    required this.senhaVisivel,
    required this.isLoading,
    this.errorMessage,
    required this.onToggleSenha,
    required this.onCriarConta,
  });

  final TextEditingController nomeController;
  final TextEditingController emailController;
  final TextEditingController telefoneController;
  final TextEditingController senhaController;
  final bool senhaVisivel;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onToggleSenha;
  final VoidCallback onCriarConta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Transform.translate(
        offset: const Offset(0, -20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadii.input),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: AppTextStyles.bodyMedium(
                            fontSize: 13,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              AuthInputField(
                label: 'NOME COMPLETO',
                placeholder: 'Ex: Maria Silva',
                icon: Icons.person_outline_rounded,
                controller: nomeController,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AuthInputField(
                label: 'E-MAIL',
                placeholder: 'seuemail@exemplo.com',
                icon: Icons.mail_outline_rounded,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AuthInputField(
                label: 'TELEFONE',
                placeholder: '(82) 99999-9999',
                icon: Icons.phone_outlined,
                controller: telefoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AuthInputField(
                label: 'SENHA',
                placeholder: 'Crie uma senha forte',
                icon: Icons.lock_outline_rounded,
                controller: senhaController,
                obscureText: !senhaVisivel,
                textInputAction: TextInputAction.done,
                trailingIcon: IconButton(
                  icon: Icon(
                    senhaVisivel
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: onToggleSenha,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onCriarConta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.border,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : Text(
                          'Criar conta',
                          style: AppTextStyles.bodyBold(
                            fontSize: 15,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Termos e política — UI pura (SRP)
// ---------------------------------------------------------------------------
class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTextStyles.bodyRegular(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          children: [
            const TextSpan(text: 'Ao se cadastrar, você concorda com os '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  // TODO: abrir Termos de Uso
                },
                child: Text(
                  'Termos de Uso',
                  style: AppTextStyles.bodyBold(
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
            const TextSpan(text: ' e '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  // TODO: abrir Política de Privacidade
                },
                child: Text(
                  'Política de Privacidade',
                  style: AppTextStyles.bodyBold(
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Link para login — UI pura (SRP)
// ---------------------------------------------------------------------------
class _LoginTrigger extends StatelessWidget {
  const _LoginTrigger();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Já tem conta? ',
          style: AppTextStyles.bodyMedium(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Text(
            'Entrar',
            style: AppTextStyles.bodyBold(
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
