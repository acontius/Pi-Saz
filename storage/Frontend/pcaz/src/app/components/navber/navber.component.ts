import { Component } from '@angular/core';
import { NavberFirstComponent } from '../navber-first/navber-first.component';
import { NavberSecondComponent } from '../navber-second/navber-second.component';
@Component({
  selector: 'app-navber',
  imports: [NavberFirstComponent],
  templateUrl: './navber.component.html',
  styleUrl: './navber.component.css'
})
export class NavberComponent {

}
