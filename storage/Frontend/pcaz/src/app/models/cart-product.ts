import Product from './product';

export default interface CartProduct {
  product: Product | undefined;
  count: number;
}
