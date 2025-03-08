import { ComponentFixture, TestBed } from '@angular/core/testing';

import { NavberSecondComponent } from './navber-second.component';

describe('NavberSecondComponent', () => {
  let component: NavberSecondComponent;
  let fixture: ComponentFixture<NavberSecondComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NavberSecondComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(NavberSecondComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
