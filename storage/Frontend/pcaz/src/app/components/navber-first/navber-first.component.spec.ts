import { ComponentFixture, TestBed } from '@angular/core/testing';

import { NavberFirstComponent } from './navber-first.component';

describe('NavberFirstComponent', () => {
  let component: NavberFirstComponent;
  let fixture: ComponentFixture<NavberFirstComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [NavberFirstComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(NavberFirstComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
