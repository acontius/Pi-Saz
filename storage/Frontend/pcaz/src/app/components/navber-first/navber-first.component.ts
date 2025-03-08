import { Component } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'navber-first',
  imports: [MatIconModule, RouterLink],
  templateUrl: './navber-first.component.html',
  styleUrl: './navber-first.component.css',
})
export class NavberFirstComponent {
  link: string;
  constructor(private authService: AuthService) {
    this.link = '/';
  }
}
