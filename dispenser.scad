// 'Dog Poop Bag Dispenser' by ahaque

// Credit for 'Container with Knurled Lid' to wstein 
// Base container can be found at https://www.thingiverse.com/thing:612709

/* [Dimensions] */

// inner diameter (for outer dimension add 2x wall thickness) - minimum = 8.0mm
diameter=34.0;

// inner height (for outer dimension add 2x wall thickness)
height=62.5;

// Select how many compartments there should be in the container - default is 1.
compartments = 1; //[1:8]

// Select width of opening for bags.
opening_width = 7; //[5:15]


/* [Appearance] */

// Name to engrave, designed for short (up to 6 letters) name.
name="Pascal";

// Second line to engrave, designed to fit 10 digit number. Leave blank to engrave nothing.
additional_line="";


// Container outside chamfer in percent of diameter. Use 0 for a flat outside bottom - default is 5% 
outside_chamfer=5.0; 

// Container inside chamfer in percent of diameter. Use 0 for a flat inner bottom - default is 2.5% 
inside_chamfer=2.5; 

/* [Thickness] */

// default value -1 means 2mm up to size 60, 2.5mm from 61 - 100. 3mm for larger.
wall_thickness=-1;

// default value -1 means take 1/2 of the container Wall Thickness
divider_wall_thickness=-1;

//thickness off container bottom. If you use the solid container model use the same value as setup in the slicer. default: -1 (use wall thickness)
container_bottom_thick=-1;

//thickness off lid top. Lid is always normal printing, so nothing special here, except reset the slicer to normal settings. default: -1 (use wall thickness)
lid_top_thick=-1;

/* [Expert] */

// to show? Only create once! You will get always all parts!
part = "container_"; // [container_:Container,lid_left_knurled_:Lid - Left Knurled, lid_right_knurled_:Lid - Right Knurled, lid_vertical_knurled_: Lid - Vertical Knurled, lid_double_knurled_:Lid - Double Knurled, lid_simple_non_knurled_:Lid - Simple Non Knurled]

// default value -1 means take 1/4 of Wall Thickness
backlash=-1;

//build a solid container, this is the key for high quality prints and also spare filament. You must print it with special settings (no infill, no top layer, bottom layer 1mm, shell thickness 1mm - must be about half of wall thickness). Works fine with Slic3r but I failed to setup Cura correct. Don't forget to reactivate top layer and infill before printing lid!
solid_container=0; //[1:true, 0:false]

quality=100; // [80:good, 100:high, 120:very high,150:best]

/* [Hidden] */

// ensure some minimal values
function diameter()=max(8,diameter);

function wall_thickness()=( 
	wall_thickness!=-1 ? max(1.0,wall_thickness) : (
	diameter() <= 20 ? 1.5 : (
	diameter() <= 60 ? 2.0 : (
	diameter() <= 100 ? 2.5 : 
   3.0))));
   
function get_divider_wall_thickness()=(divider_wall_thickness==-1?wall_thickness()/2:divider_wall_thickness);

bottom_thick=(container_bottom_thick<0?wall_thickness()/-container_bottom_thick:container_bottom_thick);
top_thick=(lid_top_thick<0?wall_thickness()/-lid_top_thick:lid_top_thick);

   
function backlash()=backlash==-1?wall_thickness()/4:max(0.2,backlash);
thread_height=(diameter()>20?diameter()/6:20/6);
function height()=max(2*(thread_height+bottom_thick),height);

$fn=quality;

lid_r=diameter()/2+wall_thickness()/2+backlash();
lid_r0=(diameter()>=20?lid_r:20/2+wall_thickness()/2+backlash()); // virtual radius, for diameter() < 20

intersection()
{
	assign(offset=(part=="both"?diameter()*.6+2*wall_thickness():0))
	union()
	{
		if(part=="container_")
		translate([0,-offset,0])
		container(diameter(),height());
		else
		translate([0,offset,(part=="cross"?height()-thread_height-wall_thickness()+bottom_thick+.1:thread_height+top_thick+wall_thickness())])
		rotate([0,(part=="cross"?0:180),0])
		lid(lid_r,lid_r0,thread_height+wall_thickness());
	}
	if(part=="cross")
	cube(200);
}

module lid(r,r0,h)
union()
{
	intersection()
	{
		translate([0,0,wall_thickness()])
		thread(r,thread_height,outer=true);

		cylinder(r=r+wall_thickness()/2,h=h);
	}

	difference()
	{
		assign(a=1.05,b=1.1)
		assign(ra=a*r+b*wall_thickness(),ra0=a*r0+b*wall_thickness(),h1=h+top_thick)
 
        if(part=="lid_right_knurled_")
        knurled(ra,ra0,h1,[1]);
        else if(part=="lid_left_knurled_")
        knurled(ra,ra0,h1,[-1]);
        else if(part=="lid_vertical_knurled_")
        knurled(ra,ra0,h1,[0]);
        else if(part=="lid_double_knurled_")
        knurled(ra,ra0,h1,[-1,1]);
        else
        cylinder(r=ra,h=h1);

		translate([0,0,-.1])
		cylinder(r=r+wall_thickness()/2,h=h+.1);
        
	}
    
    // Have ring on top of lid
    
    //translate([0, 0, r+wall_thickness()]) rotate([0, -90, 0]) linear_extrude(wall_thickness()) ring(r, wall_thickness());
}


knurled_h=[
0,
0.1757073594,
0.5271220782,
0.7116148055,
0.9007198511,
1];
knurled_rdelta=[.2,0,0.1,.3,.6,1.0];
shape_n=5;

module knurled(r,r0,height,degs)
assign(n=round(sqrt(120*(r+2*wall_thickness())*2)/shape_n)*shape_n)
assign(h_steps=len(knurled_h)-1)
assign(r_delta=-1.6*wall_thickness()/2)
//translate([0,0,height])
//rotate([180,0,0])
intersection_for(a=degs)
for(i=[0:h_steps-1])
assign(hr0=knurled_h[i],hr1=knurled_h[i+1])
assign(hr=hr1-hr0)
assign(rr0=knurled_rdelta[i],rr1=knurled_rdelta[i+1])
assign(rr=rr1-rr0)
translate([0,0,hr0*height])
rotate([0,0,35*height/r*hr0*a])
linear_extrude(convexity=10,height=hr*height,twist=-35*height/r*hr*a,scale=(r+r_delta*rr1)/(r+r_delta*rr0))
for(j=[0:n/4-1])
rotate([0,0,360/n*j])
circle(r=r+r_delta*rr0,$fn=5);


module container(r,h)
difference()
{
union()
{
    
	difference()
	{
		union()
		{
			container_hull(diameter()/2+wall_thickness(),height()+bottom_thick,outside_chamfer,[wall_thickness()/2,thread_height+wall_thickness()/2]);

			translate([0,0,height()-thread_height-wall_thickness()/2+bottom_thick])
			thread(diameter()/2+wall_thickness(),thread_height,outer=false);
		}

		if(!solid_container)
			translate([0,0,bottom_thick])

		container_hull(diameter()/2,height()+bottom_thick,inside_chamfer);
	}

	if(compartments > 1)
	{
        echo(get_divider_wall_thickness());
		for(a = [0 : 1 : compartments])
		{
			rotate((360 / compartments) * a) 
            translate([-(get_divider_wall_thickness() / 2), 0, bottom_thick])
            cube([get_divider_wall_thickness(), diameter() / 2, height()]);
		}
	}
    translate([0, -diameter + 4*wall_thickness(), h/2]) rotate([-90, 0, -90]) linear_extrude(2*wall_thickness()) ring(diameter/3, 2*wall_thickness());
};
translate([0, 0, h/2]) rotate([90, 0, 180]) curve_shape(1.1*wall_thickness() + diameter()/2, 1.2*wall_thickness(), h=h) dog_bone(opening_width, h);
linear_extrude(wall_thickness()) flower(r);
translate([0, 0, h/2]) rotate([90, 0, 160]) curve_shape(1.1*wall_thickness() + diameter()/2, .6*wall_thickness(), h=h) rotate([0, 0, 90]) text(name, size=5, halign="center");
if (additional_line != "") translate([0, 0, h/2]) rotate([90, 0, 205]) curve_shape(1.1*wall_thickness() + diameter()/2, .6*wall_thickness(), h=h) rotate([0, 0, 90]) text(additional_line, size=2, halign="center");
}

module container_hull(r,h,chamfer,thread_notch=[0,0])
{
	xn=thread_notch[0];
	yn=thread_notch[1];

	rotate_extrude(convexity=10)
	assign(x1=r*(50-chamfer)/50,x2=r,x3=r-xn,y1=r*chamfer/50,y2=h,y3=h-yn,y4=h-yn+xn)
	polygon([[0,0],[x1,0],[x2,y1],[x2,y3],[x3,y4],[x3,y2],[0,y2]]);
}

module thread(r,h,outer=false)
assign($fn=100)
{
	linear_extrude(height=h,twist=-250,convexity=10)
	for(a=[0:360/2:359])
	rotate([0,0,a])
	if(outer)
	{
		difference()
		{
			translate([0,-r])
			square(2*r);

			assign(offset=.8)
			translate([r*(1-1/offset),0])
			circle(r=1/offset*r);	
		}
	}
	else
	{
		assign(offset=.8)
		translate([(1-offset)*r,0,0])
		circle(r=r*offset);
	}
}

module dog_bone(l, h) {
circle_radius=2*l/3;
shift_x = l/2;
shift_y = h/4;
union(){
    square([l, h/2], center=true);
    translate([shift_x,shift_y,0]) circle(circle_radius);
    translate([-shift_x,shift_y,0]) circle(circle_radius);
    translate([shift_x,-shift_y,0]) circle(circle_radius);
    translate([-shift_x,-shift_y,0]) circle(circle_radius);
}
}

module flower(r) {
    d= r / 10;
    union(){
        circle(d);
        for(a=[0:6]) {
            rotate(a*60) translate([d, 0, 0]) scale([3, 1, 1]) circle(d/2);
        }
    }
}

module ring(r, t) {
    union() {
        difference(){
            translate([-r, -r, 0]) square([r, 2*r]);
            translate([-r, -r, 0]) square([r/3, 2*r]);
            circle(r);
        }
        difference() {
            circle(r);
            circle(r - t);
            translate([-r*5/3, 0, 0]) square(2*r, center=true);
        }
}
}

module curve_shape(r, t, h=100) {
// Curve 2d shape onto cylinder.
    intersection() {
        difference() {
            rotate([0,90,90]) cylinder(h, r, r, center=true);
            rotate([0,90,90]) cylinder(h, r-t, r-t, center=true);
            
        }
    linear_extrude(r) children();
    }
    
}
