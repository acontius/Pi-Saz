import { Component, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';

import { register } from 'swiper/element/bundle';

register();
@Component({
  selector: 'app-categories',
  imports: [MatIconModule],
  templateUrl: './categories.component.html',
  styleUrl: './categories.component.css',
  schemas: [CUSTOM_ELEMENTS_SCHEMA],
})
export class CategoriesComponent {}
