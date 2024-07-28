import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject var authViewModel = AuthViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Transparent background image
                Image("transparent_background") // Add your image with transparency here
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()

                    // Title
                    Text("TOURIS")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.bottom, 40) // Space between title and form

                    // Form UI
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white.opacity(0.8)) // Slightly transparent background for readability
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(maxWidth: .infinity, minHeight: 50)

                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white.opacity(0.8)) // Slightly transparent background for readability
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .frame(maxWidth: .infinity, minHeight: 50)

                        if !authViewModel.errorMessage.isEmpty {
                            Text(authViewModel.errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }

                        Button(action: {
                            authViewModel.signIn(email: email, password: password)
                        }) {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, minHeight: 50)

                        NavigationLink(destination: CreateAccountView(authViewModel: authViewModel)) {
                            Text("Create Account")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .padding()
                    .frame(width: geometry.size.width * 0.8) // Make sure form fits well within the screen
                    .background(Color.white.opacity(0.7)) // Form background to ensure readability
                    .cornerRadius(15)
                    .shadow(radius: 10)

                    Spacer()
                }
                .onTapGesture {
                    // Dismiss the keyboard when tapping outside of text fields
       //             UIApplication.shared.endEditing()
                }
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

