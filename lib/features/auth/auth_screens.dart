import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/app_store.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

String? emailValidator(String? value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
    ? null
    : 'Enter a valid email address';
String? requiredValidator(String? value) =>
    value == null || value.trim().isEmpty ? 'This field is required' : null;

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AmiaColors.pink,
    body: SafeArea(
      child: ScrollableColumn(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 44),
        children: [
          const Spacer(flex: 3),
          Image.asset(asset('amia_logo'), width: 116, height: 113),
          const SizedBox(height: 45),
          const Text(
            'Welcome to\nAmia',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              height: 1.55,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 35),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '“Connect your friends and relatives with the Mess Amia messaging system”',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.8),
            ),
          ),
          const Spacer(flex: 3),
          const SizedBox(height: 32),
          PinkButton(
            'Get started',
            white: true,
            onPressed: () => go(context, '/login'),
          ),
        ],
      ),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.signUp = false});
  final bool signUp;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  bool _obscure = true;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final store = AppScope.of(context);
    store.email = _email.text.trim();
    if (widget.signUp) {
      store.phone = _phone.text.trim();
      go(context, '/passcode');
    } else {
      store.signIn();
      home(context);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [
        if (!widget.signUp)
          TextButton(
            onPressed: () => go(context, '/signup'),
            child: const Text('Sign up'),
          ),
        const SizedBox(width: 16),
      ],
    ),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 44),
            child: IntrinsicHeight(
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.signUp ? 'Sign up' : 'Login',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: AmiaColors.blue,
                      ),
                    ),
                    const SizedBox(height: 68),
                    if (widget.signUp) ...[
                      FormFieldLine(
                        'Phone Number',
                        hint: '+123 456 789',
                        controller: _phone,
                        keyboard: TextInputType.phone,
                        validator: (v) =>
                            (v?.replaceAll(RegExp(r'\D'), '').length ?? 0) < 6
                            ? 'Enter a valid phone number'
                            : null,
                      ),
                      const SizedBox(height: 34),
                    ],
                    FormFieldLine(
                      'Email Address',
                      hint: 'ex: hello@deeper.one',
                      controller: _email,
                      keyboard: TextInputType.emailAddress,
                      validator: emailValidator,
                    ),
                    const SizedBox(height: 34),
                    FormFieldLine(
                      'Password',
                      hint: 'Password',
                      controller: _password,
                      obscure: _obscure,
                      validator: (v) => (v?.length ?? 0) < 6
                          ? 'Use at least 6 characters'
                          : null,
                      suffix: IconButton(
                        tooltip: 'Show password',
                        icon: Icon(
                          _obscure
                              ? CupertinoIcons.eye
                              : CupertinoIcons.eye_slash,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 25),
                    if (widget.signUp)
                      const Text(
                        'By signing up, you agree to our\nTerms and Privacy',
                        style: TextStyle(fontSize: 11, color: AmiaColors.muted),
                      )
                    else
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => go(context, '/forgot'),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                    const Spacer(),
                    const SizedBox(height: 40),
                    PinkButton(
                      widget.signUp ? 'Sign up' : 'Sign in',
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          if (widget.signUp) {
                            Navigator.pop(context);
                          } else {
                            go(context, '/accounts');
                          }
                        },
                        child: Text(
                          widget.signUp
                              ? 'I already have an account'
                              : 'Start with Google',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _selected = 1;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        SizedBox(
          height: 330,
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(
                  painter: SlantPainter(secondary: AmiaColors.blue),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BackButton(color: Colors.white),
                        IconButton(
                          tooltip: 'My QR code',
                          onPressed: () => go(context, '/qr'),
                          icon: const Icon(
                            CupertinoIcons.number,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Avatar('dennis', size: 110),
                    const SizedBox(height: 12),
                    const Text(
                      'Dennis',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Dennis@gmail.com',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              for (var i = 0; i < 3; i++)
                SettingRow(
                  ['Tokunaga Yae', 'Dominik Doudny', 'Corabelle Durrad'][i],
                  icon: CupertinoIcons.person_crop_circle,
                  trailing: _selected == i
                      ? const Icon(CupertinoIcons.checkmark, size: 16)
                      : const SizedBox(),
                  onTap: () => setState(() => _selected = i),
                ),
            ],
          ),
        ),
        const Spacer(),
        const Text(
          'Choose a demo account',
          style: TextStyle(color: AmiaColors.muted, fontSize: 11),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 42),
          child: PinkButton(
            'Continue as ${['Tokunaga', 'Dominik', 'Corabelle'][_selected]}',
            onPressed: () {
              final store = AppScope.of(context);
              store.name = [
                'Tokunaga Yae',
                'Dominik Doudny',
                'Corabelle Durrad',
              ][_selected];
              store.signIn();
              home(context);
            },
          ),
        ),
      ],
    ),
  );
}

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({super.key, this.reset = false});
  final bool reset;
  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  final _code = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: ScrollableColumn(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
        children: [
          Image.asset(asset('notification_art'), width: 130, height: 130),
          const SizedBox(height: 28),
          Text(
            'Enter the code for\n${AppScope.of(context).email}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AmiaColors.muted,
              height: 1.9,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 230,
            child: TextField(
              controller: _code,
              maxLength: 4,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 27,
                letterSpacing: 24,
                color: AmiaColors.blue,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••',
                errorText: _error,
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Demo verification code: 1234',
            style: TextStyle(fontSize: 11, color: AmiaColors.muted),
          ),
          const Spacer(),
          const SizedBox(height: 32),
          PinkButton(
            'Next',
            onPressed: () {
              if (_code.text != '1234') {
                setState(() => _error = 'Please enter 1234');
                return;
              }
              go(context, widget.reset ? '/reset' : '/complete-profile');
            },
          ),
        ],
      ),
    ),
  );
}

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key, this.edit = false});
  final bool edit;
  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _name;
  final _birthday = TextEditingController(text: '11/02/1990');
  String _gender = 'Male';
  bool _initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _name = TextEditingController(
        text: widget.edit ? AppScope.of(context).name : '',
      );
      _birthday.text = AppScope.of(context).birthday;
      _gender = AppScope.of(context).gender;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _birthday.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit ? 'Edit profile' : 'Your profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _form,
            child: Column(
              children: [
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => showPhotoPicker(context),
                  child: Stack(
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AmiaColors.pink),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Avatar(store.avatar, size: 140),
                        ),
                      ),
                      const Positioned(
                        right: 0,
                        bottom: 4,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            CupertinoIcons.camera,
                            color: AmiaColors.pink,
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 45),
                FormFieldLine(
                  'Full name',
                  hint: 'ex: Deeper UI Kit',
                  controller: _name,
                  validator: requiredValidator,
                ),
                const SizedBox(height: 30),
                FormFieldLine(
                  'Date of birth',
                  controller: _birthday,
                  readOnly: true,
                  suffix: const Icon(CupertinoIcons.calendar, size: 18),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      initialDate: DateTime(1990, 2, 11),
                    );
                    if (date != null) {
                      _birthday.text =
                          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                    }
                  },
                ),
                const SizedBox(height: 30),
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: ['Male', 'Female', 'Prefer not to say']
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(v, style: const TextStyle(fontSize: 13)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => _gender = v!,
                ),
                const SizedBox(height: 70),
                PinkButton(
                  widget.edit ? 'Save changes' : 'Next',
                  onPressed: () {
                    if (!_form.currentState!.validate()) return;
                    store.name = _name.text.trim();
                    store.birthday = _birthday.text;
                    store.gender = _gender;
                    store.changed();
                    if (widget.edit) {
                      Navigator.pop(context);
                      toast(context, 'Profile updated');
                    } else {
                      go(context, '/address');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showPhotoPicker(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _PhotoPicker(),
    );

class _PhotoPicker extends StatefulWidget {
  const _PhotoPicker();
  @override
  State<_PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<_PhotoPicker> {
  String _selected = 'dennis';
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(28, 0, 28, 30),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Choose a photo',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children:
              ['dennis', 'mattie', 'rahul', 'amolika', 'story_1', 'story_4']
                  .map(
                    (image) => GestureDetector(
                      onTap: () => setState(() => _selected = image),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selected == image
                                ? AmiaColors.pink
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Avatar(image, radius: 8, size: 80),
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 20),
        PinkButton(
          'Use photo',
          onPressed: () {
            final store = AppScope.of(context);
            store.avatar = _selected;
            store.changed();
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return Scaffold(
      backgroundColor: AmiaColors.ink,
      appBar: AppBar(backgroundColor: AmiaColors.ink),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Avatar(store.avatar, size: 110),
            const SizedBox(height: 20),
            Text(
              store.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              store.email,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const Spacer(),
            Center(
              child: QrImageView(
                data: 'amia://contact/${Uri.encodeComponent(store.email)}',
                size: 220,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AmiaColors.yellow,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AmiaColors.yellow,
                ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                toast(context, 'Share this code to connect with friends');
              },
              child: const Text(
                'Share your QR Code',
                style: TextStyle(color: AmiaColors.pink),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});
  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _address = TextEditingController(text: 'New York');
  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Positioned.fill(child: Image.asset(asset('map'), fit: BoxFit.cover)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: BackButton(color: Colors.white),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AmiaColors.ink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _address,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Your address',
                      labelStyle: TextStyle(color: Colors.white70),
                      suffixIcon: Icon(
                        CupertinoIcons.search,
                        color: AmiaColors.pink,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  CupertinoIcons.location_solid,
                  size: 44,
                  color: AmiaColors.pink,
                ),
                const Spacer(),
                PinkButton(
                  'Start',
                  onPressed: () {
                    if (_address.text.trim().isEmpty) {
                      toast(context, 'Enter your address');
                      return;
                    }
                    final store = AppScope.of(context);
                    store.address = _address.text.trim();
                    store.signIn();
                    home(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key, this.forgot = false});
  final bool forgot;
  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _value = TextEditingController();
  final _confirm = TextEditingController();
  @override
  void dispose() {
    _value.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.forgot ? 'Forgot password' : 'Change password'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _form,
        child: ScrollableColumn(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 35),
            FormFieldLine(
              widget.forgot ? 'Email Address' : 'New password',
              controller: _value,
              hint: widget.forgot
                  ? 'hello@deeper.one'
                  : 'At least 6 characters',
              obscure: !widget.forgot,
              validator: widget.forgot
                  ? emailValidator
                  : (v) => (v?.length ?? 0) < 6
                        ? 'Use at least 6 characters'
                        : null,
            ),
            if (!widget.forgot) ...[
              const SizedBox(height: 28),
              FormFieldLine(
                'Confirm password',
                controller: _confirm,
                obscure: true,
                validator: (v) =>
                    v != _value.text ? 'Passwords do not match' : null,
              ),
            ],
            const SizedBox(height: 30),
            const Text(
              'This is an offline account preview. No email is sent and no password is stored.',
              style: TextStyle(
                fontSize: 12,
                color: AmiaColors.muted,
                height: 1.8,
              ),
            ),
            const Spacer(),
            PinkButton(
              widget.forgot ? 'Continue' : 'Done',
              onPressed: () {
                if (!_form.currentState!.validate()) return;
                if (widget.forgot) {
                  AppScope.of(context).email = _value.text.trim();
                  go(context, '/passcode-reset');
                } else {
                  Navigator.popUntil(
                    context,
                    (route) =>
                        route.settings.name == '/profile' ||
                        route.settings.name == '/login' ||
                        route.isFirst,
                  );
                  toast(context, 'Password form completed');
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}
