import { Component, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';
import {register} from 'swiper/element/bundle';

register();

@Component({
  selector: 'app-carousel',
  imports: [MatIconModule],
  templateUrl: './carousel.component.html',
  styleUrl: './carousel.component.css',
  schemas:[CUSTOM_ELEMENTS_SCHEMA],
})
export class CarouselComponent {}
