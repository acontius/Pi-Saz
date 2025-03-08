import { Component } from '@angular/core';
import { CartListComponent } from '../../components/cart-list/cart-list.component';

@Component({
  selector: 'app-cart',
  imports: [CartListComponent],
  templateUrl: './cart.component.html',
  styleUrl: './cart.component.css'
})
export class CartComponent {

}
