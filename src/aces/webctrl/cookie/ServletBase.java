package aces.webctrl.cookie;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
/**
 * This is used as a base class for most servlets.
 * Thrown errors and HTML resources are handled automatically.
 */
public abstract class ServletBase extends HttpServlet {
  /**
   * This is the primary method which subclasses will want to override.
   * When a GET or POST request is made, this method will be invoked.
   */
  public abstract void exec(HttpServletRequest req, HttpServletResponse res) throws Throwable;
  /**
   * This method specifies that GET requests are handled identically to POST requests.
   */
  @Override public void doGet(final HttpServletRequest req, final HttpServletResponse res) throws ServletException, IOException {
    doPost(req,res);
  }
  /**
   * This is the primary method wrapping our overridden {@code exec} method.
   */
  @Override public void doPost(final HttpServletRequest req, final HttpServletResponse res) throws ServletException, IOException {
    try{
      req.setCharacterEncoding("UTF-8");
      res.setCharacterEncoding("UTF-8");
      res.addHeader("Cache-Control", "no-cache, no-store, must-revalidate");
      exec(req,res);
    }catch(NumberFormatException e){
      res.sendError(400, "Failed to parse number from string.");
    }catch(Throwable t){
      if (!res.isCommitted()){
        res.reset();
        res.setCharacterEncoding("UTF-8");
        res.addHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        res.setContentType("text/plain");
        res.setStatus(500);
        t.printStackTrace(res.getWriter());
      }
    }
  }
}