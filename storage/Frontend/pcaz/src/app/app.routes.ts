import { Routes } from '@angular/router';
import { HomeComponent } from './pages/home/home.component';
import { AuthComponent } from './pages/auth/auth.component';
import { RegistrationFormComponent } from './components/registration-form/registration-form.component';
import { UserDataComponent } from './pages/user-data/user-data.component';
import { UserComponent } from './pages/user/user.component';
import { CartComponent } from './pages/cart/cart.component';
export const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'auth', component: AuthComponent },
  { path: 'test', component: RegistrationFormComponent },
  { path: 'user', component: UserComponent },
  { path: 'user/userdata', component: UserDataComponent },
  { path: 'cart', component: CartComponent },
];
