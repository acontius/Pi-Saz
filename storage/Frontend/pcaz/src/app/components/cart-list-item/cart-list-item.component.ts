import { Component, Input, input } from '@angular/core';
import CartProduct from '../../models/cart-product';

@Component({
  selector: 'app-cart-list-item',
  imports: [],
  templateUrl: './cart-list-item.component.html',
  styleUrl: './cart-list-item.component.css',
})
export class CartListItemComponent {
  // @Input({ required: true }) cartListItem: CartProduct;
  // constructor() {
  //   this.cartListItem = {
  //     product: undefined,
  //     count: 0,
  //   };
  // }
}
