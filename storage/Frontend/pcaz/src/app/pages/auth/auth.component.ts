import { Component } from '@angular/core';
import {
  FormBuilder,
  FormGroup,
  Validators,
  ReactiveFormsModule,
} from '@angular/forms';
import { catchError } from 'rxjs/operators';
import { of } from 'rxjs';
import { AuthService, AuthResponse } from '../../services/auth.service';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-auth',
  imports: [ReactiveFormsModule, CommonModule],
  templateUrl: './auth.component.html',
  styleUrls: ['./auth.component.css'],
})
export class AuthComponent {
  isLogin = true; // Toggle between login and signup
  form: FormGroup;

  constructor(private fb: FormBuilder, private authService: AuthService) {
    this.form = this.fb.group({
      phone: [
        '',
        [
          Validators.required,
          Validators.pattern(/^\+\d{2} \d{3} \d{3} \d{4}$/),
        ],
      ],
      password: ['', Validators.required],
    });
  }

  onSubmit() {
    if (this.form.valid) {
      const { phone, password } = this.form.value;

      const request = this.isLogin
        ? this.authService.login(phone, password)
        : this.authService.signup(phone, password);

      request
        .pipe(
          catchError((error) => {
            console.error('Error occurred:', error);
            // Handle error (e.g., show a message to the user)
            return of(null); // Return a null observable to complete the stream
          })
        )
        .subscribe({
          next: (response: AuthResponse | null) => {
            if (response) {
              console.log('Success:', response);
              // Store the token if login is successful
              this.authService.storeToken(response.token);
              // Handle successful response (e.g., redirect, show a success message)
            } else {
              // Handle the case where the response is null (error occurred)
              console.error('Authentication failed');
            }
          },
          error: (error:string) => {
            // Handle any errors that were not caught in the pipe
            console.error('An error occurred:', error);
          },
          complete: () => {
            // Optional: Code to run when the observable completes
            console.log('Request completed');
          },
        });
    }
  }

  onToggle() {
    this.isLogin = !this.isLogin;
    this.form.reset();
  }
}
