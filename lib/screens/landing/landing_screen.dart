import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/button.dart';
import '../../widgets/screen.dart';
import '../../router/routing_constants.dart';
import '../../widgets/spaced_column.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      title: landingRoute.title,
      hideBottomNavbar: true,
      hideAppBar: true,
      child: const Column(
        children: [
          HeroImage(),
          LandingScreenContent(),
        ],
      ),
    );
  }
}

class LandingScreenContent extends StatelessWidget {
  const LandingScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      "Manage your finances and expenses easily, with Solaris",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      "Manage finances, your wallet, make payments and receipts of finances easily and simply",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff667085),
                      ),
                    ),
                  ),
                ],
              ),
            ]),
            SpacedColumn(
              space: 10,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: "Login",
                    onPressed: () {
                      context.push(loginRoute.path);
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: SecondaryButton(
                    text: "Signup",
                    onPressed: () {
                      context.push(signupRoute.path);
                    },
                  ),
                ),
                // SizedBox(
                //   width: double.infinity,
                //   child: PrimaryButton(
                //     text: "Create device binding",
                //     onPressed: () async {
                //       await DeviceUtilService.getDeviceFingerprint(
                //         "bf50e494417b400480dbfeeb2a94a30e",
                //       );
                //     },
                //   ),
                // ),
                // SizedBox(
                //   width: double.infinity,
                //   child: PrimaryButton(
                //     text: "Get device signature",
                //     onPressed: () async {
                //       await DeviceUtilService.getDeviceFingerprint(
                //         "bf50e494417b400480dbfeeb2a94a30e",
                //       );
                //     },
                //   ),
                // ),
                // SizedBox(
                //   width: double.infinity,
                //   child: PrimaryButton(
                //     text: "Get key pair",
                //     onPressed: () async {
                //       await DeviceUtilService.getECDSAP256KeyPair();
                //     },
                //   ),
                // ),
                // SizedBox(
                //   width: double.infinity,
                //   child: PrimaryButton(
                //     text: "Get signature",
                //     onPressed: () async {
                //       await DeviceUtilService.signMessage(
                //         "One time password",
                //         "BE5MCLS7bsFmC2jAwazBhJfctWA4MOvdYTwB5CZBA3v2Jc8vP949zVapBN35HLqlyjoqkITN9UmpWVhQA4R9SgTucCKdFHB68DLkOp43Juue5725nKW0Oq2JMecYf2ZEUg==",
                //       );
                //     },
                //   ),
                // ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class HeroImage extends StatelessWidget {
  const HeroImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xffD9D9D9),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Icon(
        Icons.image_outlined,
        size: 100,
        color: Color(0xff747474),
      ),
    );
  }
}
