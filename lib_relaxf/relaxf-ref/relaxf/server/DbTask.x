/**
 * Created by IntelliJ IDEA.
 * User: jim
 * Date: 5/29/12
 * Time: 2:27 AM
 * To change this template use File | Settings | File Templates.
 */
@Retention(RetentionPolicy.RUNTIME)
@Target( {FIELD, LOCAL_VARIABLE, TYPE, ANNOTATION_TYPE, CONSTRUCTOR, PACKAGE, PARAMETER})
public @interface DbTask {
 DbTerminal[] value();
}
