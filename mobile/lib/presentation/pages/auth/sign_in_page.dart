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
import 'package:passai/presentation/widgets/auth/google_icon.dart';
import 'package:passai/presentation/widgets/auth/social_button.dart';

/// Tela de login do Passaí.
///
/// Segue Clean Architecture + SOLID:
/// - Nenhuma lógica de negócio aqui (SRP)
/// - Depende de [SignInNotifier] via abstração Riverpod (DIP)
/// - UI apenas observa estado e delega ações ao notifier
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// Delega o login ao [SignInNotifier] — zero lógica aqui.
  Future<void> _onEntrar() async {
    setState(() => _errorMessage = null);
    await ref.read(signInNotifierProvider.notifier).login(
          email: _emailController.text,
          senha: _senhaController.text,
        );
  }

  /// Observa o estado após mudança e reage (navegação ou erro).
  void _onStateChanged(AsyncValue<dynamic>? previous, AsyncValue<dynamic> next) {
    if (!mounted) return;

    next.whenOrNull(
      data: (user) {
        if (user != null) {
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
    // Observa mudanças de estado para reagir (efeito colateral)
    ref.listen(signInNotifierProvider, _onStateChanged);

    final isLoading = ref.watch(signInNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeroBanner(
              titulo: 'Bem-vindo de volta!',
              subtitulo: 'Insira suas credenciais para continuar sua jornada',
            ),
            _LoginCard(
              emailController: _emailController,
              senhaController: _senhaController,
              senhaVisivel: _senhaVisivel,
              isLoading: isLoading,
              errorMessage: _errorMessage,
              onToggleSenha: () =>
                  setState(() => _senhaVisivel = !_senhaVisivel),
              onEntrar: _onEntrar,
            ),
            const SizedBox(height: 8),
            const _DividerRow(),
            const SizedBox(height: 16),
            const _SocialGrid(),
            const SizedBox(height: 24),
            const _RegisterTrigger(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card de credenciais — UI pura, sem lógica de negócio (SRP)
// ---------------------------------------------------------------------------
class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailController,
    required this.senhaController,
    required this.senhaVisivel,
    required this.isLoading,
    this.errorMessage,
    required this.onToggleSenha,
    required this.onEntrar,
  });

  final TextEditingController emailController;
  final TextEditingController senhaController;
  final bool senhaVisivel;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onToggleSenha;
  final VoidCallback onEntrar;

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
                label: 'E-MAIL',
                placeholder: 'seuemail@exemplo.com',
                icon: Icons.mail_outline_rounded,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AuthInputField(
                label: 'SENHA',
                placeholder: '••••••••',
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // TODO: navegar para recuperação de senha
                  },
                  child: Text(
                    'Esqueceu a senha?',
                    style: AppTextStyles.bodyBold(
                      fontSize: 14,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onEntrar,
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
                          'Entrar',
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
// Divider "ou entre com" — UI pura (SRP)
// ---------------------------------------------------------------------------
class _DividerRow extends StatelessWidget {
  const _DividerRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'ou entre com',
              style: AppTextStyles.bodySemibold(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grade de botões sociais — UI pura (SRP)
// ---------------------------------------------------------------------------
class _SocialGrid extends StatelessWidget {
  const _SocialGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SocialButton(
              label: 'Google',
              iconWidget: const GoogleIcon(size: 22),
              onTap: () {
                // TODO: login com Google via Supabase Auth OAuth
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SocialButton(
              label: 'Apple',
              iconWidget: const Icon(
                Icons.apple,
                size: 22,
                color: AppColors.textPrimary,
              ),
              onTap: () {
                // TODO: login com Apple via Supabase Auth OAuth
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Link para cadastro — UI pura (SRP)
// ---------------------------------------------------------------------------
class _RegisterTrigger extends StatelessWidget {
  const _RegisterTrigger();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Não tem conta? ',
          style: AppTextStyles.bodyMedium(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.signUp),
          child: Text(
            'Cadastre-se',
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
