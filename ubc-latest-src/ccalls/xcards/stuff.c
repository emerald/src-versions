From the xforms free object manual page.
Note the use of fl_get_vclass and fl_winget.


   void draw_triangle(int fill, int x, int y, int w, int h, FL_COLOR col)
   {
        XPoint xp[4];
        GC gc = fl_state[fl_get_vclass()].gc[0];
        Window win = fl_winget();
        Display *disp = fl_get_display();
   
        xp[0].x = x;         xp[0].y = y + h - 1;
        xp[1].x = x + w/2;   xp[1].y = y;
        xp[2].x = x + w - 1; xp[2].y = y + h - 1;
        XSetForeground(disp, gc, fl_get_pixel(col));
        if(fill)
          XFillPolygon (disp, win, gc, xp, 3, Nonconvex, Unsorted);
        else
        {
            xp[3].x = xp[0].x; xp[3].y = xp[0].y;
            XDrawLines(disp, win, gc, xp, 4, CoordModeOrigin);
        }
   }
