import 'package:flutter/material.dart';
import '../auth/user_login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController pageController = PageController();
  int currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/3.JPG",
      "text": "Explore many products!"
    },
    {
      "image": "assets/images/4.JPG",
      "text": "Choose and checkout easily."
    },
    {
      "image": "assets/images/9.JPG",
      "text": "Get it delivered right to your door!"
    },
  ];

  void goToNextPage() {
    if (currentPage == onboardingData.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserLoginScreen(),
        ),
      );
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToPreviousPage() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF5F7), Color(0xFFFCEFEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// TOP ROW
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Back arrow (only when page > 0)
                    currentPage > 0
                        ? IconButton(
                            onPressed: goToPreviousPage,
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Color(0xFF773D44),
                            ),
                          )
                        : const SizedBox(width: 48),

                    /// Skip Button
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserLoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          color: Color(0xFF773D44),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// PAGE VIEW
              Expanded(
                flex: 4,
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (value) {
                    setState(() => currentPage = value);
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) => OnboardContent(
                    image: onboardingData[index]["image"]!,
                    text: onboardingData[index]["text"]!,
                  ),
                ),
              ),

              /// DOT INDICATOR
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    height: 10,
                    width: currentPage == index ? 25 : 10,
                    decoration: BoxDecoration(
                      gradient: currentPage == index
                          ? const LinearGradient(
                              colors: [Color(0xFF773D44), Color(0xFFFFA1B5)],
                            )
                          : null,
                      color: currentPage == index
                          ? null
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// NEXT / GET STARTED BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: const Color(0xFF773D44),
                    elevation: 5,
                  ),
                  onPressed: goToNextPage,
                  child: Text(
                    currentPage == onboardingData.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardContent extends StatelessWidget {
  final String image;
  final String text;

  const OnboardContent({
    super.key,
    required this.image,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// IMAGE CONTAINER
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        /// TEXT BELOW IMAGE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF773D44),
              fontFamily: 'Poppins',
            ),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}
